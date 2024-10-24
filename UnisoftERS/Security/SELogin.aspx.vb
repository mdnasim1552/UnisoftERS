Imports System.Web.Services
Imports System.Web.Script.Services
Imports System.Drawing
Imports Telerik.Web.UI
Imports System.Web.Configuration
Imports System.DirectoryServices.AccountManagement
Imports System.Web.Hosting
Imports DevExpress.Data.Helpers
Imports DevExpress.CodeParser

Partial Class Security_Login
    Inherits System.Web.UI.Page '  PageBase
    Dim _license As New License(ConfigurationManager.AppSettings("Unisoft.LicenseKey"))
    Public Shared bSystemDisabled As Boolean
    Public Shared sUserID As String = ""
    Public Shared sPassWD As String = ""
    Public Shared sDomain As String = ""
    Public Shared sOpHospital As String = ""
    Public Shared bActiveDirectory As Boolean = ConfigurationManager.AppSettings("Unisoft.ActiveDirectoryLogin")

    Protected Sub Page_Load(sender As Object, e As System.EventArgs) Handles Me.Load

        If Not Page.IsPostBack Then

            If HttpContext.Current.Request.IsAuthenticated And Not bActiveDirectory Then
                usernamediv.Visible = False
                passworddiv.Visible = False
                ResetDiv.Visible = False
            End If

            Dim expiryNotice As Integer = CType(ConfigurationManager.AppSettings("LicenseMessageDaysBefore"), Integer)
            If Date.ParseExact(_license.ExpiryDate, "dd/MM/yyyy", System.Globalization.DateTimeFormatInfo.InvariantInfo) < Now Then
                Dim expiredMessage As String = ConfigurationManager.AppSettings("LicenseExpiredMessage")
                expiredMessage = Replace(expiredMessage, "%%ExpiryDate%%", _license.ExpiryDate)
                licenseExpired.Value = expiredMessage
            ElseIf Date.ParseExact(_license.ExpiryDate, "dd/MM/yyyy", System.Globalization.DateTimeFormatInfo.InvariantInfo) < DateAdd(DateInterval.Day, expiryNotice, Now) Then
                Dim expiringMessage As String = ConfigurationManager.AppSettings("LicenseExpiringMessage")
                expiringMessage = Replace(expiringMessage, "%%ExpiryDate%%", _license.ExpiryDate)
                licenseExpired.Value = expiringMessage
            End If
            If Not (Session("isSSO") = "True") Then
                Session.Clear()
                PageReset()

            End If

            'Dim logOut As Security_Logout = New Security_Logout()
            If HttpContext.Current IsNot Nothing Then
                Dim cookieCount As Int16 = HttpContext.Current.Request.Cookies.Count

                For i As Integer = 0 To cookieCount - 1
                    ' Get single cookie from list
                    Dim Cookie = HttpContext.Current.Request.Cookies(i)

                    If Cookie IsNot Nothing Then
                        If Cookie.Name = "patientId" Then
                            HttpContext.Current.Response.Cookies("patientId").Value = ""
                            HttpContext.Current.Response.Cookies("patientId").Expires = DateTime.Now.AddDays(-1)
                        End If

                    End If
                Next
            End If

        End If
        Dim roomId As Integer = CInt(Request.QueryString("roomId"))

        If roomId > 0 Then
            Session("RoomId") = IIf(DataAdapter.CheckRoomId(roomId), roomId, 0)
            Session("TrustId") = DataAdapter.GetTrustIdByRoomId(roomId)
        End If
        InitSystem()
        'Querystring "CNN" implemented for Beacon hospital (3001)
        If Not IsPostBack Then
            If Request.QueryString("CNN") IsNot Nothing AndAlso CBool(ConfigurationManager.AppSettings("Unisoft.AllowCNNLogin")) Then
                InitADLogin()
            End If

            'Get trusts, id only one trust exists, select it and hide the trust div, otherwise default to the first trust in the list
            Dim TrustList
            If (Session("isSSO") = "True" And ConfigurationManager.AppSettings("TrustNamePassedInSSOADGroupName") = "Y") Then
                TrustList = DataAdapter.GetTrustsFromSSOADGroupName(Session("AzureADGroups"))
            Else
                TrustList = DataAdapter.GetTrusts()
            End If
            txtTrustName.Items.Clear()

            Dim trustName = Request.QueryString("Trust")
            Dim selectedIndex = 0
            If TrustList.Rows.Count > 0 Then
                For Each r As DataRow In TrustList.Rows
                    Dim i As RadComboBoxItem = New RadComboBoxItem()
                    i.Text = r("TrustName")
                    i.Value = r("TrustId")
                    If (r("TrustName") = trustName) Then
                        selectedIndex = txtTrustName.Items.Count
                    End If
                    txtTrustName.Items.Add(i)
                Next
                txtTrustName.SelectedIndex = selectedIndex
                If txtTrustName.Items.Count = 1 Then
                    trustDiv.Visible = False
                End If
            End If
            Session("TrustId") = txtTrustName.SelectedValue
            With txtOperatingHospital
                .Items.Clear()
                .DataSource = DataAdapter.GetOperatingHospitalsRooms(Session("TrustId"))
                .DataBind()
            End With
            'txtOperatingHospital.Items.Clear()
            'txtOperatingHospital.ClearSelection()
            If Session("RoomId") > 0 Then
                txtTrustName.SelectedValue = txtTrustName.FindItemByValue(DataAdapter.GetTrustIdByRoomId(Session("RoomId"))).Value
                txtTrustName.Enabled = False
                Session("RoomName") = DataAdapter.GetRoomNameByRoomId(Session("RoomId"))
                Session("HospitalName") = DataAdapter.GetHospitalNameByRoomId(Session("RoomId"))
                txtOperatingHospital.Text = Session("RoomName")
                txtOperatingHospital.Enabled = False
                txtOperatingHospital.Value = Session("RoomId")
            Else
                txtOperatingHospital.Index = -1
                txtOperatingHospital.Enabled = True
            End If

        End If
    End Sub

    Sub SetSessionPCName()
        'Dim bAllowExternalNetwork As Boolean = ConfigurationManager.AppSettings("Unisoft.AllowExternalNetwork")
        'Session("RoomName") = 
        'Try
        '    'Get hostname of computer from local network
        '    Session("PCName") = System.Net.Dns.GetHostEntry(Request.ServerVariables("REMOTE_HOST").ToString).HostName.Trim
        '    If Session("PCName") = "" Then
        '        Session("PCName") = Utilities.GetIPAddress()
        '    End If
        '    If Not bAllowExternalNetwork AndAlso Not CheckIfLocalNetwork() Then
        '        Response.Redirect("~/Security/NetworkErr.aspx", True)
        '    End If
        'Catch ex As Exception
        '    If bAllowExternalNetwork Then
        '        Session("PCName") = Utilities.GetIPAddress() 'System.Net.Dns.GetHostName.Trim
        '    Else
        '        'Error Message
        '        Response.Redirect("~/Security/NetworkErr.aspx", True)
        '    End If
        'End Try
    End Sub

    Protected Function CheckIfLocalNetwork() As Boolean
        Dim sIPAddress As String = Request.UserHostAddress
        'Dim xx As String = Environment.MachineName
        'Dim sMess As String = "alert('UserHostAddress->" & sIPAddress & " --- MachineName->" & xx & " --- PCName->" & Session("PCName") & "');"
        'ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "blankpdf", sMess, True)
        'ScriptManager.RegisterStartupScript(Me, Me.[GetType](), "key01", sMess, True)
        If sIPAddress.StartsWith("10.") Or sIPAddress.StartsWith("172.") Or sIPAddress.StartsWith("192.168") Or sIPAddress.StartsWith("::1") Then
            'Dim xx As String = Environment.MachineName
            Return True
        End If
        Return False
    End Function


    Protected Sub InitSystem()
        Dim sessionHelper As New SessionManager
        Dim sErs As String = "0"
        sessionHelper.SetInitialSessions()

        Dim versionObj As New Version(Session(Constants.SESSION_APPVERSION))
        ' issue 4426
        Me.lblAppVersion.Text = "Version: " & versionObj.Major & "." & versionObj.Minor & "." & versionObj.Build
        Me.lblAppVersion.ToolTip = versionObj.Major & "." & versionObj.Minor & "." & versionObj.Build & "." & versionObj.Revision
        ' 4426


        Me.lblCopyright.Text = "Copyright &copy; 2018 - " & DateTime.Now.Year & " HD Clinical Ltd"


        If Not IsPostBack Then
            Dim dbList As New List(Of String)
            dbList = GetDatabaseConfig()
            txtDatabaseName.Items.Clear()
            databasediv.Attributes.Add("Style", "display:normal;padding-top: 5px; text-align: right;")
            If dbList.Count > 0 Then

                If dbList.Count > 1 Then
                    txtDatabaseName.Items.Insert(0, New RadComboBoxItem())
                End If
                For Each db In dbList
                    Dim dbItem As RadComboBoxItem = New RadComboBoxItem()
                    Dim dbName As String = db.Split("|")(0)
                    dbItem.Text = dbName
                    dbItem.Value = dbName

                    Try
                        sErs = db.Split("|")(1)
                    Catch ex As Exception
                        sErs = "0"
                        'Either param not specified or wrong param in web.config for Unisoft.SetupKeys, carry on with default as ERSViewer (0). Value for ERS is 1
                    End Try

                    dbItem.Attributes.Add("IsERS", sErs)
                    txtDatabaseName.Items.Add(dbItem)
                Next
                txtDatabaseName.DataBind()

                If dbList.Count = 1 Then
                    txtDatabaseName.Items(0).Selected = True
                    ' txtDatabaseName.SelectedValue = dbList.Item(0).Split("|")(0)
                    RaiseEvent DatabaseChanged(Me, New EventArgs())
                    databasediv.Attributes.Add("Style", "display:none")
                Else
                    'With txtDatabaseName
                    '    .DataSource = dbList
                    '    .DataBind()
                    '    .Items.Insert(0, New RadComboBoxItem())
                    'End With
                    If Not Request.Cookies("DbInfo") Is Nothing Then
                        Dim aCookie As HttpCookie = Request.Cookies("DbInfo")
                        txtDatabaseName.SelectedValue = Server.HtmlEncode(aCookie.Value)
                        RaiseEvent DatabaseChanged(Me, New EventArgs())
                    End If
                    If txtDatabaseName.SelectedValue = "" Then 'And Request.QueryString("CNN") IsNot Nothing Then
                        txtDatabaseName.SelectedValue = dbList.Item(0).Split("|")(0)
                        DatabaseSelection()
                    End If
                End If
            End If
        End If

        Try
            If txtDatabaseName.SelectedItem.Attributes("IsERS") = "1" AndAlso _license.ExpiryDate > Now AndAlso Not _license.IsERSViewer Then
                Session("isERSViewer") = 0
            Else
                Session("isERSViewer") = 1
            End If

        Catch ex As Exception
            Session("isERSViewer") = 0 'Any error, set application to read-only (ErsViewer)
        End Try


        'For testing only-----------------------------
        'txtUserID.Text = "admin"
        'txtPassWD.Text = "admin"
        'InitLogin()
        '---------------------------------------------
    End Sub
    Public Event DatabaseChanged(ByVal sender As Object, ByVal e As EventArgs)

    Private Sub LoginCmd_Click(sender As Object, e As EventArgs) Handles LoginCmd.Click
        InitLogin()
    End Sub

    Protected Sub PageReset()
        Me.txtUserID.Text = ""
        Me.txtPassWD.Text = ""

        NewPasswordRadTextBox.Text = ""
        ConfirmPasswordRadTextBox.Text = ""

        sysMessage.Style("display") = "None"

        Session("UserID") = ""
        Session("PassWD") = ""
        Session("FullName") = ""
        Session("PageID") = ""
        Session("Role") = 0
        Session("Authenticated") = False
        Session("AccountExpired") = False
        Session("SkinName") = "Unisoft"
        Session("HideStartUpCharts") = False
        Session("Suppressed") = False
        Session("IsSSO") = False
        Session("AzureADGroups") = ""
        Session("DisplayName") = ""
        Session("UserID") = ""
        Session("GivenName") = ""
        Session("SurName") = ""
        Session("SSOIDPMode") = ""
    End Sub

    Protected Sub InitLogin()
        Try
            Dim da As New DataAccess
            Dim sMsg As String = ""
            Dim bNoLogon As Boolean = False
            If HttpContext.Current.Request.IsAuthenticated And Not bActiveDirectory Then
                sUserID = System.Environment.UserName
            Else
                sUserID = LCase(Trim(txtUserID.Text))
                sPassWD = Trim(txtPassWD.Text)
            End If



            If Session("isSSO") = "True" Then
                sUserID = Session("UserID")
                da.LoginSuccess(sUserID)
            End If

            sOpHospital = IIf(Utilities.GetInt(txtOperatingHospital.Value) Is Nothing Or Utilities.GetInt(txtOperatingHospital.Value) = 0, "", Utilities.GetInt(txtOperatingHospital.Value))

            If sUserID = "" Then
                sMsg = "Please enter a valid Username"
                bNoLogon = True
            ElseIf sPassWD = "" And Not HttpContext.Current.Request.IsAuthenticated Then
                sMsg = "Please enter a valid Password"
                bNoLogon = True
                'ElseIf sPassWD = "" And Not bActiveDirectory Then
                '    sMsg = "Please enter a valid Password"
                '    bNoLogon = True
            ElseIf sOpHospital = "" Then
                sMsg = "Please select an Operating Hospital"
                bNoLogon = True
            Else
                sMsg = chkOperatingHospital()
                If sMsg = "" Then sMsg = chkDatabase()
                If sMsg <> "" Then bNoLogon = True
            End If

            If bNoLogon = True Then
                ShowError(sMsg)
            End If

            If bNoLogon = False Then
                If sUserID <> "" Then
                    If sPassWD <> "" Or HttpContext.Current.Request.IsAuthenticated Then
                        If Session("RoomName") Is Nothing Then SetSessionPCName()
                        ValidateLogin()
                    End If
                End If
            End If
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while Logging in!!", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem logging in.")
            RadNotification1.Show()
        End Try
    End Sub

    Private Function chkOperatingHospital() As String
        Dim da As New DataAccess
        Dim OperatingHospitalCount As Integer = da.GetOperatingHospitalCount
        If OperatingHospitalCount < 0 Or OperatingHospitalCount > CInt(_license.RegisteredHospital) Or _license.HospitalID <> ConfigurationManager.AppSettings("Unisoft.HospitalID") Then
            Return ("License is not valid for this hospital or its operating hospital(s).")
        End If
        Return ""
    End Function

    Private Function chkDatabase() As String
        Dim getRegisteredProduct As String = _license.RegisteredProductText
        Dim iERS_DB As Integer = Convert.ToInt16(getRegisteredProduct.Substring(8, 1))
        Dim iERSViewer_DB As Integer = Convert.ToInt16(getRegisteredProduct.Substring(9, 1))
        Dim iChkERS As Integer = 0
        Dim iChkERS_Viewer As Integer = 0

        For i As Integer = 0 To txtDatabaseName.Items.Count - 1
            If txtDatabaseName.Items(i).Attributes("IsERS") = "1" Then
                iChkERS += 1
            ElseIf txtDatabaseName.Items(i).Attributes("IsERS") = "0" Then
                iChkERS_Viewer += 1
            End If
        Next

        If iChkERS > iERS_DB Or iChkERS_Viewer > iERSViewer_DB Then 'Hospital should use less or same number of databases assigned to their licence
            Return ("License is not valid for this hospital or its operating hospital(s).")
        End If
        Return ""
    End Function

    Protected Sub InitADLogin()
        Try
            Dim sMsg As String = ""
            Dim bNoLogon As Boolean = False

            'sMsg = chkOperatingHospital()
            If sMsg <> "" Then bNoLogon = True

            If bNoLogon = True Then
                ShowError(sMsg)
            Else
                ValidateLogin()
            End If
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occurred while Logging in!!", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem logging in.")
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub ValidateLogin()
        Dim da As New DataAccess
        Dim resetPwd As Boolean
        Dim bActiveDirectory As Boolean = ConfigurationManager.AppSettings("Unisoft.ActiveDirectoryLogin")
        Dim readOnlyAccess As Boolean = ConfigurationManager.AppSettings("ActiveDirectoryReadOnlyDefault")
        Dim offsetMinutes As Integer = CInt(Session("TimezoneOffset"))

        Session("UserID") = sUserID
        Session("PassWD") = sPassWD
        'Session("OperatingHospitalID") = Utilities.GetInt(txtOperatingHospital.Value)
        Dim imagePortName As String = hfPortName.Value
        Dim roomId As String = txtOperatingHospital.Value
        Dim roomName As String = txtOperatingHospital.Text
        Session("RoomId") = roomId
        Session("RoomName") = roomName
        If Session("TrustId") = "" Then
            Session("TrustId") = DataAdapter.GetTrustIdByRoomId(roomId)
        End If
        Session("OperatingHospitalIdsForTrust") = BusinessLogic.GetOperatingHospitalIdsForTrust(CInt(HttpContext.Current.Session("TrustId")))
        Session(Constants.SESSION_HEALTH_SERVICE_NAME) = da.GetCustomText("CountryOfOriginHealthService")

        Session("OperatingHospitalID") = da.GetOperatingHospitalID(roomId)
        'Session("RoomID") = txtOperatingHospital.
        'txtOperatingHospital.Items. 
        'txtOperatingHospital.FindControl
        'txtOperatingHospital.GetAllItems
        'txtOperatingHospital. 
        'User Unisoft
        If String.Compare(sUserID, "unisoft", True) = 0 Then
            Dim tmp As Double = CInt(Session("SecCode")) / 951
            Dim correctPwd As String = CStr(tmp).Substring(CStr(tmp).IndexOf(".") + 1, 4)
            If sPassWD = correctPwd Then
                Session("Role") = 99 'Super user
                Session("Authenticated") = True
                Session("FullName") = "Administrator"
                Session("LoggedOn") = DateTime.UtcNow.AddMinutes(-offsetMinutes).ToString("dd/MM/yyyy HH:mm")
                Session("PKUserId") = "-9999" '-9999 set as Unisoft user
                LoadForm()
                Exit Sub
            End If
        End If

        If HttpContext.Current.Request.IsAuthenticated Then ' Or bActiveDirectory Then
            'Make sure the user is in the AD group allowed for login
            Dim userValid As String
            If Session("isSSO") = "True" Then
                userValid = ""
            Else
                userValid = isGroupMember()
            End If

            If userValid = "" Then
                If Not bActiveDirectory Then 'Passthrough Authentication
                    Session("Authenticated") = True
                    Session("FullName") = sUserID
                    Session("LoggedOn") = DateTime.UtcNow.AddMinutes(-offsetMinutes).ToString("dd/MM/yyyy HH:mm")
                    Dim sValidateUser As String = LogicAdapter.ValidateUser(sUserID, sPassWD, resetPwd, CInt(Session("OperatingHospitalID")))
                    If sValidateUser <> "" Then
                        da.LoginFailure(sUserID, sValidateUser)
                        If Not Session("Authenticated") Then
                            ShowError(sValidateUser)
                            Exit Sub
                        Else
                            ShowInfo(sValidateUser)
                        End If
                    Else
                        da.LoginSuccess(sUserID)
                    End If
                Else

                    ' Need to check the password entered is valid against AD
                    Dim sDomainUser = Request.LogonUserIdentity.Name

                    Dim configDomain = ConfigurationManager.AppSettings("ActiveDirectoryDomainOverride")

                    If Not String.IsNullOrEmpty(configDomain) Then
                        sDomain = configDomain
                    Else
                        sDomain = sDomainUser.Substring(0, sDomainUser.IndexOf("\"))
                    End If

                    If ValidateActiveDirectoryLogin(sDomain, sUserID, sPassWD) Then
                        sUserID = sUserID.Substring(sUserID.IndexOf("\") + 1)

                        Session("Authenticated") = True
                        Session("FullName") = sUserID
                        Session("LoggedOn") = DateTime.UtcNow.AddMinutes(-offsetMinutes).ToString("dd/MM/yyyy HH:mm")
                    Else
                        Session("Authenticated") = False
                        ShowError(da.GetCustomText("LoginNotAuthorised"))
                        Exit Sub
                    End If

                    Dim sValidateUser As String = LogicAdapter.ValidateUser(sUserID, sPassWD, resetPwd, CInt(Session("OperatingHospitalID")))

                    If sValidateUser <> "" Then
                        da.LoginFailure(sUserID, sValidateUser)
                        ShowError(sValidateUser)
                        Exit Sub
                    Else
                        da.LoginSuccess(sUserID)
                    End If


                End If

            Else
                ShowError(userValid)
                Exit Sub
            End If
        Else

            If Not bActiveDirectory Then
                Dim sValidateUser As String = LogicAdapter.ValidateUser(sUserID, sPassWD, resetPwd, CInt(Session("OperatingHospitalID")))
                If sValidateUser <> "" Then
                    da.LoginFailure(sUserID, sValidateUser)
                    If Not Session("Authenticated") Then
                        ShowError(sValidateUser)
                        Exit Sub
                    Else
                        ShowInfo(sValidateUser)
                    End If
                Else
                    da.LoginSuccess(sUserID)
                End If
            End If

        End If

        If CBool(Session("AccountExpired")) And Not readOnlyAccess Then
            Audit_LoginStatus(LoginAttempt.EXPIRED_ACCOUNT)
            PageReset()
            ShowError(da.GetCustomText("LoginAccountSuppressed") + "</br></br>" + da.GetCustomText("GeneralContactSupport"))
        Else
            If Session("UserLoggedOnPreviously") Then
                PageReset()
                Dim loggedOnErr As String = da.GetCustomText("LoginAlreadyLoggedIn") '"Another user seems to have logged on with the same user name"
                If Session("UserLoggedOnPreviouslyHostName") IsNot Nothing AndAlso Not String.IsNullOrEmpty(CStr(Session("UserLoggedOnPreviouslyHostName"))) Then
                    loggedOnErr = Session("UserLoggedOnPreviouslyHostName") & " : " & loggedOnErr
                Else
                    loggedOnErr = loggedOnErr
                End If
                ShowError(loggedOnErr)
                Exit Sub
            End If

            If CBool(Session("Authenticated")) Then
                '### First Write the UserLogin to the Table... And store the MasterLoginId for this User.. This Master LoginId will be used every where else for all sorts of Activities!
                Audit_LoginStatus(LoginAttempt.SUCCESS)

                If resetPwd Then
                    ShowInfo(da.GetCustomText("LoginChangePassword"))
                    LoginDiv.Visible = False
                    PasswordResetDiv.Style("display") = "normal"
                    PasswordResetUsernameRadTextBox.Text = CStr(Session("UserID"))
                Else
                    LoadForm()
                End If


            Else
                '### Write the Fail Attempt to the Table... 
                Audit_LoginStatus(LoginAttempt.FAILED)

                PageReset()
                ShowError(da.GetCustomText("LoginUsernameOrPasswordIncorrect"))

            End If
        End If
    End Sub

    Private Function ValidateActiveDirectoryLogin(ByVal Domain As String, ByVal Username As String, ByVal Password As String) As Boolean
        Dim Success As Boolean = False
        Dim useSecureLdap As Boolean = ConfigurationManager.AppSettings("Unisoft.UseSecureActiveDirectory")
        Dim Entry As DirectoryServices.DirectoryEntry
        Dim strPath As String = "LDAP://" & Domain

        If useSecureLdap Then
            strPath = strPath & ":636"
        End If

        'If String.IsNullOrEmpty(Password) Then
        Entry = New DirectoryServices.DirectoryEntry(strPath, Username, Password)
        'Entry = New DirectoryServices.DirectoryEntry(strPath)
        'Else
        'Entry = New DirectoryServices.DirectoryEntry(strPath, Username, Password)
        'End If

        Dim Searcher As New System.DirectoryServices.DirectorySearcher(Entry)
        Searcher.SearchScope = DirectoryServices.SearchScope.OneLevel

        Try
            Dim Results As System.DirectoryServices.SearchResult = Searcher.FindOne()
            Success = Not (Results Is Nothing)
        Catch ex As Exception
            'Dim strMessage As String = ex.Message.ToString
            Success = False
        End Try
        Return Success
    End Function

    Private Function isGroupMember() As String
        Dim retString As String
        Dim sDomainUser = Request.LogonUserIdentity.Name

        Dim configDomain = ConfigurationManager.AppSettings("ActiveDirectoryDomainOverride")

        If Not String.IsNullOrEmpty(configDomain) Then
            sDomain = configDomain
        Else
            sDomain = sDomainUser.Substring(0, sDomainUser.IndexOf("\"))
        End If

        Dim arrGroup As New List(Of String)
        If Not IsNothing(WebConfigurationManager.AppSettings("Unisoft.ActiveDirectoryGroups")) Then
            Dim grpString As String = WebConfigurationManager.AppSettings("Unisoft.ActiveDirectoryGroups")
            For Each grp In grpString.Split(",").ToList
                arrGroup.Add(grp)
            Next
        End If

        'Dim groupList As List(Of String) = New List(Of String)(New String() {"unisoft gastro admin", "unisoft gastro regular", "unisoft gastro read only"})

        Try
            Using HostingEnvironment.Impersonate()
                Using ctx As New PrincipalContext(ContextType.Domain, sDomain)
                    ' find the user in the identity store
                    Dim user As UserPrincipal = UserPrincipal.FindByIdentity(ctx, sUserID)
                    Try
                        ' get the groups for the user principal 
                        Using groups As PrincipalSearchResult(Of Principal) = user.GetAuthorizationGroups()
                            For Each group As Principal In groups
                                For Each groupName As String In arrGroup
                                    If group.ToString().ToLower = groupName.ToLower.Trim Then
                                        Return ""
                                    End If
                                Next
                                'group.Dispose()
                            Next
                        End Using
                    Catch ex As Exception
                        'Return "Unable to get uner principle for domain " + sDomain & ": " + ex.ToString()
                        Return "User does not exist under this domain."
                    End Try
                End Using
            End Using
        Catch ex As Exception
            Return "Error in PrincipalContext: " + ex.ToString()
        End Try

        Return "Unauthorized user"
    End Function

    Protected Sub LoadForm()

        ClearAndProceedToLogin()

        'If Not CBool(_license.IsERSViewer) AndAlso DataAdapter.isUserExist(Session("RoomName"), Session("UserID")) = 1 Then  'Check not required for ERS Viewer
        '    'isLockUserLabel.Text = "There is an existing user with the name. Do you want to kick that person out?"
        '    Dim msg As String = DataAdapter.isUserExistLogOutMessages(Session("RoomName"), Session("UserID"))
        '    Dim script As String = "$('#isLockUserLabel').text('" & msg & "'); function f(){$find(""" + RadWindow1.ClientID & """).show(); Sys.Application.remove_load(f);}Sys.Application.add_load(f);"
        '    ScriptManager.RegisterStartupScript(Me, Me.[GetType](), "key01", script, True)
        'Else
        '    ProceedToLogin()

        '    ''check for image port registered to PC
        '    ''Dim imagePort = Products_Default.GetPCImagePort(Session("PCName").ToString(), CInt(Session("OperatingHospitalID")))
        '    'If Not CBool(_license.IsERSViewer) Then
        '    '    'check if the questions been asked already
        '    '    If DataAdapter.PCLogCheck(CInt(Session("OperatingHospitalID"))) = False Then
        '    '        Dim hTable As DataTable = DataAdapter.GetAvailableImagePorts(CInt(Session("OperatingHospitalID")))

        '    '        'Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{ImagePortsComboxBox, ""}}, hTable, "PortName", "ImagePortId")
        '    '        'ImagePortsComboxBox.DataBind() 

        '    '        'if not, ask the question
        '    '        Dim script As String = "$find(""" + ImagePortConfigurationRadWindow.ClientID & """).show();"
        '    '        ScriptManager.RegisterStartupScript(Me, Me.[GetType](), "key02", script, True)
        '    '    Else
        '    '        ProceedToLogin()
        '    '    End If
        '    'Else
        '    '    ProceedToLogin()
        '    'End If
        'End If
    End Sub
    Protected Sub ClearAndProceedToLogin()
        DataAdapter.clearExistingUser(Session("RoomName"), Session("UserID"))
        ProceedToLogin()
    End Sub
    '08 Mar 2021 : Mahfuz added ImportPatientByWebService
    Protected Sub ProceedToLogin()
        'Dim op As New Options
        'Dim timeOutValue = op.GetApplicationTimeOut()
        'If timeOutValue = 0 Then
        '    Throw New ApplicationException("ApplicationTimeOut is not set properly in ERS_SystemConfig table for the operating hospital id " & CStr(Session("OperatingHospitalID")) & ".")
        'End If
        'Session.Timeout = timeOutValue

        Session("PageID") = 1


        Dim sQueryString As String = ""
        If Request.QueryString("CNN") IsNot Nothing Then
            sQueryString = Request.QueryString("CNN")
        End If

        If txtDatabaseName.SelectedValue = "" Then
            txtDatabaseName.Items(0).Selected = True
        End If

        'Response.Cookies("PcInfo")("HospitalID") = Session("OperatingHospitalID")
        Response.Cookies("DbInfo").Value = txtDatabaseName.SelectedValue
        Response.Cookies("DbInfo").Expires = DateTime.Now.AddYears(10)
        'Response.Cookies("PcInfo")("PCName") = pcName
        '
        'Session("isERSViewer") = _license.IsERSViewer
        Session("IsDemoVersion") = _license.IsDemoVersion
        Session(Constants.SESSION_PHOTO_URL) = GetPhotoUrl()
        Session(Constants.SESSION_PHOTO_UNC) = GetPhotoUnc()
        Session(Constants.SESSION_IMPORT_PATIENT_BY_WEBSERVICE) = GetImportPatientByWebservice()
        Session(Constants.SESSION_IMPORT_PATIENT_BY_NSSAPI) = GetImportPatientByWebservice()
        Session(Constants.SESSION_IMPORT_PATIENT_BY_NHSSPINEAPI) = GetImportPatientByWebservice()

        'MH added on 17 Nov 2021
        Session(Constants.SESSION_ADD_EXPORT_FILE_FOR_MIRTH) = GetAddExportFileForMirth()

        'MH added on 22 Mar 2022
        Session(Constants.SESSION_SUPPRESS_MAIN_REPORT_PDF) = GetSuppressMainReportPDF()

        DataAdapter.SaveLoginPcDetail(Session("RoomName"), IIf(Session("OperatingHospitalID") Is Nothing, 0, Session("OperatingHospitalID")), Session("UserID"))
        DataAccess_Sch.ReleaseRedundantLockedSlots()
        DataAccess_Sch.ReleaseRedundantLockedSlots(CInt(Session("PKUserId")))
        PreaparPageHeaderRoomTitle()

        Session("NEDFailuresNotified") = Nothing 'set to nothing so that NED failures are checked once logged in

        If sQueryString <> "" Then
            Response.Redirect("~/Products/Default.aspx?CNN=" & sQueryString, False)
        Else
            Response.Redirect("~/Products/Default.aspx", False)
        End If
    End Sub
    Protected Sub Page_PreInit(sender As Object, e As System.EventArgs) Handles Me.PreInit
        ' PageReset()
    End Sub

    Protected Sub PasswordResetConfirmButton_Click(sender As Object, e As EventArgs) Handles PasswordResetConfirmButton.Click
        If NewPasswordRadTextBox.Text.Trim() = "" Then
            PageReset()
            ShowError("Please enter a valid password.")
            Exit Sub
        End If

        If NewPasswordRadTextBox.Text <> ConfirmPasswordRadTextBox.Text Then
            PageReset()
            ShowError("Passwords do not match. Please try again.")
            Exit Sub
        End If

        'sOpHospital = IIf(Utilities.GetInt(txtOperatingHospitalResetPass.SelectedValue) Is Nothing, "", Utilities.GetInt(txtOperatingHospitalResetPass.SelectedValue))

        'If sOpHospital = "" Then
        '    PageReset()
        '    ShowError("Please select an Operating Hospital.")
        '    Exit Sub
        'End If

        'Session("OperatingHospitalID") = Utilities.GetInt(sOpHospital)

        Dim pwdFormatValid As Boolean
        Dim pwdFormatErrors As List(Of String) = LogicAdapter.IsPasswordFormatValid(NewPasswordRadTextBox.Text, pwdFormatValid)
        If Not pwdFormatValid Then
            PageReset()
            ShowError(pwdFormatErrors)
            Exit Sub
        End If

        Dim bl As New BusinessLogic
        Dim da As New DataAccess
        da.UpdateUserResetPassword(CInt(Session("PKUserId")), NewPasswordRadTextBox.Text, bl.GetPasswordExpiryDate(), False)

        ShowInfo("Password changed successfully. Please login with your new password.")
        'txtOperatingHospital.Value = sOpHospital
        txtUserID.Text = CStr(Session("UserID"))
        LoginDiv.Visible = True
        LoginDiv.Style("display") = "normal"
        PasswordResetDiv.Style("display") = "none"
        txtUserID.Text = ""
        txtPassWD.Text = ""
    End Sub

    'Protected Sub RadAjaxManager1_AjaxRequest(sender As Object, e As AjaxRequestEventArgs) Handles RadAjaxManager1.AjaxRequest
    '    If txtUserID.Text.Trim() <> "" Then
    '        If String.Compare(txtUserID.Text, "unisoft", True) = 0 Then
    '            Session("SecCode") = GetRandom(1000, 9999)
    '            SecurityCodeLabel.Text = "Security Code: " & Session("SecCode")
    '            txtPassWD.Focus()
    '        ElseIf Not IsNothing(Session("ConnectionDatabaseName")) AndAlso LogicAdapter.IsFirstTimeLogin(txtUserID.Text) Then
    '            SecurityCodeLabel.Text = ""
    '            ShowInfo("Please change your password as this is your first time login.")
    '            'txtPassWD.Focus()
    '            LoginDiv.Style("display") = "none"
    '            PasswordResetDiv.Style("display") = "normal"
    '            'Utilities.LoadDropdown(txtOperatingHospitalResetPass, DataAdapter.GetOperatingHospitals, "HospitalName", "OperatingHospitalId", "")
    '            PasswordResetUsernameRadTextBox.Text = txtUserID.Text
    '            NewPasswordRadTextBox.Focus()
    '            Session("UserID") = txtUserID.Text
    '        Else
    '            'If IsDBNull(Session("OperatingHospitalID")) OrElse Session("OperatingHospitalID") Is Nothing Then
    '            '    txtOperatingHospital.SelectedValue = 0
    '            'Else
    '            '    txtOperatingHospital.SelectedValue = Session("OperatingHospitalID")
    '            'End If
    '            txtPassWD.Focus()
    '        End If
    '        'ScriptManager.RegisterStartupScript(Page, GetType(Page), "myscript", "HandlePasswordTextBoxesInIE();", True)
    '    End If
    'End Sub

    Public Function GetRandom(ByVal Min As Integer, ByVal Max As Integer) As Integer
        Dim Generator As System.Random = New System.Random()
        Return Generator.Next(Min, Max)
    End Function

    Private Sub ShowError(ByVal errorMessage As String)
        txtSysMessage.Text = errorMessage
        ' txtSysMessageDiv.Style("background-color") = "lightgrey" ' "#303030" '"#FFCECE" ' "#E4C4C4"
        txtSysMessage.ForeColor = Color.Red
        'txtSysMessage.Font.Bold = True
        'txtSysMessage.Text = String.Format("<b>Error</b><br />{0}", errorMessage)

        sysMessage.Style("display") = "normal"
    End Sub

    Private Sub ShowError(ByVal errorMessages As List(Of String))
        Dim errMsg As New StringBuilder

        If errorMessages IsNot Nothing AndAlso errorMessages.Count > 0 Then
            ' errMsg.Append("<b>Error</b>")
            For Each errorMessage As String In errorMessages
                errMsg.Append(String.Format("<br />{0}", errorMessage))
            Next

            txtSysMessageDiv.Style("background-color") = "lightgrey" ' "#FFCECE" '"#E4C4C4"
            txtSysMessage.ForeColor = Color.Red
            txtSysMessage.Text = errMsg.ToString()
            sysMessage.Style("display") = "block"
        End If
    End Sub

    Private Sub ShowInfo(ByVal msg As String)
        'txtSysMessageDiv.Style("background-color") = "lightgrey" '  ' "#C4E4C4"
        txtSysMessage.ForeColor = Color.Green
        txtSysMessage.Text = msg
        sysMessage.Style("display") = "block"
    End Sub

    Protected Sub PasswordResetCancelButton_Click(sender As Object, e As EventArgs) Handles PasswordResetCancelButton.Click
        Response.Redirect(Request.Url.AbsoluteUri, False)
    End Sub

    Public Function GetDatabaseConfig() As List(Of String)
        Dim dbList As New List(Of String)
        If Not IsNothing(WebConfigurationManager.AppSettings("Unisoft.SetupKeys")) Then
            Dim configString As String = WebConfigurationManager.AppSettings("Unisoft.SetupKeys")
            For Each dbstr In configString.Split("~").ToList
                dbList.Add(dbstr.ToString)
                'sDB_Name = dbstr.Split("|")(0)
            Next
        End If
        Return dbList
    End Function
    Private _logicAdapter As BusinessLogic = Nothing
    Private _dataAdapter As DataAccess = Nothing
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

    Private Sub txtDatabaseName_TextChanged(sender As Object, e As EventArgs) Handles txtDatabaseName.SelectedIndexChanged
        'DatabaseSelection()
    End Sub
    Private Sub dbchanged(sender As Object, e As EventArgs) Handles Me.DatabaseChanged
        DatabaseSelection()
    End Sub
    Sub DatabaseSelection()

        Session.Remove("ConnectionDatabaseName")
        DataAccess.ConnectionStr = Nothing
        'txtOperatingHospital.Enabled = True
        hospitaldiv.Attributes.Add("Style", "display:normal;padding-top: 5px; text-align: right;")
        If txtDatabaseName.SelectedValue <> Nothing AndAlso txtDatabaseName.SelectedValue <> "" Then
            Dim selectedDB As String = txtDatabaseName.SelectedValue
            Session("ConnectionDatabaseName") = txtDatabaseName.SelectedValue
            'Session(Constants.SESSION_PHOTO_URL) = GetPhotoUrl(selectedDB)
            DataAccess.ConnectionStr = selectedDB
            Dim pcTable As DataTable = DataAdapter.GetLoginPCDetails(Session("RoomName"), Session("UserID"))
            'Dim hTable As DataTable = DataAdapter.GetOperatingHospitals("")
            'Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{txtOperatingHospital, ""}}, hTable, "HospitalName", "OperatingHospitalId")



            'Utilities.LoadDropdown(txtOperatingHospital, hTable, "HospitalName", "OperatingHospitalId", Nothing)
            'If Not IsNothing(pcTable) AndAlso pcTable.Rows.Count > 0 Then
            '    txtOperatingHospital.SelectedValue = pcTable.Rows(0).Item("OperatingHospitalID")
            '    hospitaldiv.Attributes.Add("Style", "display:none")
            '    'txtOperatingHospital.Enabled = False
            'ElseIf hTable.Rows.Count = 1 Then
            '    txtOperatingHospital.SelectedIndex = 1
            '    hospitaldiv.Attributes.Add("Style", "display:none")
            '    'txtOperatingHospital.Enabled = False
            'End If

        End If
    End Sub
    Public Function GetPhotoUrl_OLD(dbName As String) As String
        Dim photo As String = ""
        If Not IsNothing(WebConfigurationManager.AppSettings("Unisoft.SetupKeys")) Then
            Dim configString As String = WebConfigurationManager.AppSettings("Unisoft.SetupKeys")
            For Each dbstr In configString.Split("~").ToList
                If dbstr.Split("|")(0) = dbName Then
                    photo = dbstr.Split("|")(1)
                End If
            Next
        End If
        Return photo
    End Function

    Public Function GetPhotoUrl() As String
        Dim path = DataAdapter.GetPhotoURL(CInt(Session("OperatingHospitalID")))
        Return path
    End Function

    Public Function GetPhotoUnc() As String
        Dim path = DataAdapter.GetPhotoUNC(CInt(Session("OperatingHospitalID")))
        Return path
    End Function
    Public Function GetImportPatientByWebservice() As Integer

        Dim intOption As Integer = 0

        intOption = DataAdapter.GetImportPatientByWebservice(CInt(Session("OperatingHospitalID")))

        Return intOption
    End Function
    Public Function GetSuppressMainReportPDF() As Boolean

        Dim blnOption As Boolean = False

        blnOption = DataAdapter.GetSuppressMainReportPDFFlag(CInt(Session("OperatingHospitalID")))

        Return blnOption
    End Function
    Public Function GetAddExportFileForMirth() As Boolean

        Dim blnOption As Boolean = False

        blnOption = DataAdapter.GetAddExportFileForMirthFlag(CInt(Session("OperatingHospitalID")))

        Return blnOption
    End Function

    'Protected Sub QuickLoginButton_Click(sender As Object, e As EventArgs) Handles QuickLoginButton.Click

    '    txtUserID.Text = "admin"
    '    txtPassWD.Text = "admin"

    '    InitLogin()
    'End Sub

    Private Enum LoginAttempt
        SUCCESS = 1
        FAILED = 2
        EXPIRED_ACCOUNT = 3
    End Enum

    Private Sub Audit_LoginStatus(ByVal loginAttempt As LoginAttempt)
        '### First Write the UserLogin to the Table... And store the MasterLoginId for this User.. This Master LoginId will be used every where else for all sorts of Activities!
        Dim log As New AuditLogManager
        Session(Constants.SESSION_MASTER_AUDIT_LOGID) = log.WriteLogInDetailsMasterLog()

        Try
            If loginAttempt = Security_Login.LoginAttempt.SUCCESS Then
                log.WriteActivityLog(EVENT_TYPE.LogIn, "Successful Login- UserId: " & sUserID)
            ElseIf loginAttempt = Security_Login.LoginAttempt.FAILED Then
                log.WriteActivityLog(EVENT_TYPE.LogIn, "Invalid Login attempt- UserId: " & sUserID)
            ElseIf loginAttempt = Security_Login.LoginAttempt.EXPIRED_ACCOUNT Then
                log.WriteActivityLog(EVENT_TYPE.LogIn, "Attempt to Login with an Expired Account- UserId: " & sUserID)
            End If
        Catch ex As Exception
            log.Dispose()
        End Try
    End Sub

    Private Sub NoImagePortButton_Click(sender As Object, e As EventArgs) Handles NoImagePortButton.Click
        ProceedToLogin()
    End Sub

    Private Sub IPCheckNoButton_Click(sender As Object, e As EventArgs) Handles IPCheckNoButton.Click
        ProceedToLogin()
    End Sub

    Private Sub ImagePortSelectionOk_Click(sender As Object, e As EventArgs) Handles ImagePortSelectionOk.Click
        Dim imageportId = CInt(ImagePortsComboxBox.SelectedValue)
        Dim isStatic As Boolean = CBool(hdStatic.Value)
        DataAdapter.UpdatePCSImagePort(Session("RoomId").ToString, imageportId, isStatic)
        ProceedToLogin()
    End Sub

    Protected Sub txtDatabaseName_SelectedIndexChanged(sender As Object, e As Object)
        RaiseEvent DatabaseChanged(Me, New EventArgs())
    End Sub

    Private Sub txtTrustName_SelectedIndexChanged(sender As Object, e As RadComboBoxSelectedIndexChangedEventArgs) Handles txtTrustName.SelectedIndexChanged
        Session("TrustId") = txtTrustName.SelectedValue
        With txtOperatingHospital
            .Items.Clear()
            .DataSource = DataAdapter.GetOperatingHospitalsRooms(Session("TrustId"))
            .DataBind()
        End With
    End Sub
    Private Sub PreaparPageHeaderRoomTitle()
        Session("PageHeaderRoomTitle") = Session("RoomName")
    End Sub
    Private Sub insertUserWithGroup(ByVal username As String,
                               ByVal title As String,
                               ByVal forename As String,
                               ByVal surname As String,
                               ByVal initials As String,
                               ByVal groups As String,
                               ByRef userId As Integer)
        Dim da As New DataAccess

    End Sub

    <WebMethod()>
    Public Shared Sub SetTimezoneOffset(timezoneOffset As Integer)
        HttpContext.Current.Session("TimezoneOffset") = timezoneOffset
    End Sub
End Class
