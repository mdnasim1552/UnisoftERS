Imports Microsoft.VisualBasic
Imports System
Imports Telerik.Web
Imports Telerik.Web.UI
Imports System.Drawing

Public Class Utilities
    Inherits System.Web.UI.Page

    Public Shared Sub LoadDropdown(ByVal cContent As Dictionary(Of RadDropDownList, String),
                                        Optional dtList As DataTable = Nothing,
                                        Optional textField As String = "ListItemText",
                                        Optional valueField As String = "ListItemNo",
                                        Optional dataBind As Boolean = True)

        If cContent.Count <= 0 Then Exit Sub

        If dtList Is Nothing Then
            Dim sText As String = ""
            For Each cCnt As KeyValuePair(Of RadDropDownList, String) In cContent
                If cCnt.Value Is Nothing Then Continue For
                Dim da As New DataAccess
                dtList = da.GetList_Arr(cCnt.Value)

                Dim radcbo As RadDropDownList = cCnt.Key
                'Dim AllowAddNewItem As Boolean = dtList.Columns.Contains("FirstItemText")  'FirstItemText is present only for data from ERS_List

                Dim dvList As DataView = dtList.DefaultView
                If cContent.Count > 1 Then dvList.RowFilter = "ListDescription = '" & cCnt.Value & "'" 'Filter only if more than 1 comboBox
                radcbo.ToolTip = cCnt.Value
                LoadDropdownItem(radcbo, dvList, textField, valueField, dataBind)

            Next
        Else
            For Each cCnt As KeyValuePair(Of RadDropDownList, String) In cContent
                Dim radcbo As RadDropDownList = cCnt.Key
                'Dim AllowAddNewItem As Boolean = dtList.Columns.Contains("FirstItemText")  'FirstItemText is present only for data from ERS_List

                Dim dvList As DataView = dtList.DefaultView
                If cContent.Count > 1 Then dvList.RowFilter = "ListDescription = '" & cCnt.Value & "'" 'Filter only if more than 1 comboBox
                radcbo.ToolTip = cCnt.Value
                LoadDropdownItem(radcbo, dvList, textField, valueField, dataBind)
            Next

        End If
    End Sub

    Public Shared Sub LoadDropdown(ByVal cContent As Dictionary(Of RadComboBox, String),
                                        Optional dtList As DataTable = Nothing,
                                        Optional textField As String = "ListItemText",
                                        Optional valueField As String = "ListItemNo",
                                        Optional dataBind As Boolean = True)

        If cContent.Count <= 0 Then Exit Sub

        If dtList Is Nothing Then
            Dim sText As String = ""
            For Each cCnt As KeyValuePair(Of RadComboBox, String) In cContent
                If cCnt.Value Is Nothing Then Continue For
                Dim da As New DataAccess
                'Added by rony tfs-4175
                Dim dropdownID = cCnt.Value
                dtList = da.GetList_Arr(cCnt.Value)

                Dim radcbo As RadComboBox = cCnt.Key
                'Dim AllowAddNewItem As Boolean = dtList.Columns.Contains("FirstItemText")  'FirstItemText is present only for data from ERS_List

                Dim dvList As DataView = dtList.DefaultView
                If cContent.Count > 1 Then dvList.RowFilter = "ListDescription = '" & cCnt.Value.Replace("'", "''") & "'" 'Filter only if more than 1 comboBox
                radcbo.ToolTip = cCnt.Value
                LoadDropdownItem(radcbo, dvList, textField, valueField, dataBind, dropdownID) 'Added by rony tfs-4175

            Next
        Else
            For Each cCnt As KeyValuePair(Of RadComboBox, String) In cContent
                Dim radcbo As RadComboBox = cCnt.Key
                'Dim AllowAddNewItem As Boolean = dtList.Columns.Contains("FirstItemText")  'FirstItemText is present only for data from ERS_List

                Dim dvList As DataView = dtList.DefaultView
                If cContent.Count > 1 Then dvList.RowFilter = "ListDescription = '" & cCnt.Value & "'" 'Filter only if more than 1 comboBox
                radcbo.ToolTip = cCnt.Value
                LoadDropdownItem(radcbo, dvList, textField, valueField, dataBind, "") 'Added by rony tfs-4175
            Next

        End If
    End Sub

    Public Shared Sub LoadDropdown(ByVal cContent As Dictionary(Of DropDownList, String),
                                        Optional dtList As DataTable = Nothing,
                                        Optional textField As String = "ListItemText",
                                        Optional valueField As String = "ListItemNo",
                                        Optional dataBind As Boolean = True)

        If cContent.Count <= 0 Then Exit Sub

        If dtList Is Nothing Then
            Dim sText As String = ""
            For Each cCnt As KeyValuePair(Of DropDownList, String) In cContent
                sText += "'" & cCnt.Value & "',"
            Next
            If Right(sText, 1) = "," Then sText = sText.TrimEnd(CChar(","))

            Dim da As New DataAccess
            dtList = da.GetList_Arr(sText)
        End If

        For Each cCnt As KeyValuePair(Of DropDownList, String) In cContent
            Dim radcbo As DropDownList = cCnt.Key
            'Dim AllowAddNewItem As Boolean = dtList.Columns.Contains("FirstItemText")  'FirstItemText is present only for data from ERS_List

            Dim dvList As DataView = dtList.DefaultView
            If cContent.Count > 1 Then dvList.RowFilter = "ListDescription = '" & cCnt.Value & "'" 'Filter only if more than 1 comboBox
            radcbo.ToolTip = cCnt.Value
            LoadDropdownItem(radcbo, dvList, textField, valueField, dataBind)
        Next
    End Sub

    Private Shared Sub LoadDropdownItem(ByVal radcbo As RadComboBox, ByVal dvList As DataView, ByVal textField As String,
                                        ByVal valueField As String, ByVal dataBind As Boolean, ByVal dropdownID As String) 'Added by rony tfs-4175

        Dim bAllowAddNewItem As Boolean = False

        Try
            With radcbo
                .ClearSelection()
                .Items.Clear()
                .DataSource = dvList
                .DataTextField = textField
                .DataValueField = valueField
                'DevNote: Avoid doing DataBind() when the RadComboBox is within RadGrrid's FilterTemplate. 
                'Otherwise duplicates will be inserted!!! Probably a Telerik bug.
                If dataBind Then
                    .DataBind()
                End If

                If Not dvList Is Nothing AndAlso dvList.Count > 0 Then
                    Dim columns As DataColumnCollection = dvList.ToTable().Columns

                    'Add First Item
                    'Added by rony tfs-4175
                    If columns.Contains("FirstItemText") AndAlso Not IsDBNull(dvList(0)("FirstItemText")) AndAlso dropdownID <> "List Type" Then
                        .Items.Insert(0, New RadComboBoxItem(dvList(0)("FirstItemText").ToString()))
                    End If

                    If columns.Contains("AllowAddNewItemUserSetting") AndAlso Not String.IsNullOrEmpty(dvList(0)("AllowAddNewItemUserSetting")) AndAlso CBool(dvList(0)("AllowAddNewItemUserSetting")) = True Then bAllowAddNewItem = True

                Else
                    bAllowAddNewItem = True
                End If

                If bAllowAddNewItem Then

                    If dvList.Count <= 0 Then .Items.Insert(0, New RadComboBoxItem("")) 'Insert a blank entry if list is empty

                    radcbo.Items.Add(New RadComboBoxItem() With {
                        .Text = "Add new",
                        .Value = -55,
                        .ImageUrl = "~/images/icons/add.png",
                        .CssClass = "comboNewItem"
                        })
                    radcbo.Attributes.Add("onchange", "if (typeof AddNewItemPopUp === 'function') { AddNewItemPopUp(" & radcbo.ClientID & "); } else { window.parent.AddNewItemPopUp(" & radcbo.ClientID & ");" & " }")
                End If
            End With
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while creating new procedure.", ex)
        End Try
    End Sub

    Private Shared Sub LoadDropdownItem(ByVal radcbo As RadDropDownList, ByVal dvList As DataView, ByVal textField As String,
                                        ByVal valueField As String, ByVal dataBind As Boolean)

        Dim bAllowAddNewItem As Boolean = False

        Try
            With radcbo
                .ClearSelection()
                .Items.Clear()
                .DataSource = dvList
                .DataTextField = textField
                .DataValueField = valueField
                'DevNote: Avoid doing DataBind() when the RadComboBox is within RadGrrid's FilterTemplate. 
                'Otherwise duplicates will be inserted!!! Probably a Telerik bug.
                If dataBind Then
                    .DataBind()
                End If

                If Not dvList Is Nothing AndAlso dvList.Count > 0 Then
                    Dim columns As DataColumnCollection = dvList.ToTable().Columns

                    'Add First Item
                    If columns.Contains("FirstItemText") AndAlso Not IsDBNull(dvList(0)("FirstItemText")) Then
                        '.Items.Add(New ListItem(dvList(0)("FirstItemText").ToString()))
                    End If

                    If columns.Contains("AllowAddNewItemUserSetting") AndAlso Not String.IsNullOrEmpty(dvList(0)("AllowAddNewItemUserSetting")) AndAlso CBool(dvList(0)("AllowAddNewItemUserSetting")) = True Then bAllowAddNewItem = True

                Else
                    bAllowAddNewItem = True 'If the list is EMPTY, let the user add the first item irrespective of bAllowAddNewItem
                End If
            End With
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occurred while creating new procedure.", ex)
        End Try
    End Sub

    Private Shared Sub LoadDropdownItem(ByVal radcbo As DropDownList, ByVal dvList As DataView, ByVal textField As String,
                                        ByVal valueField As String, ByVal dataBind As Boolean)

        Dim bAllowAddNewItem As Boolean = False

        Try
            With radcbo
                .ClearSelection()
                .Items.Clear()
                .DataSource = dvList
                .DataTextField = textField
                .DataValueField = valueField
                'DevNote: Avoid doing DataBind() when the RadComboBox is within RadGrrid's FilterTemplate. 
                'Otherwise duplicates will be inserted!!! Probably a Telerik bug.
                If dataBind Then
                    .DataBind()
                End If

                If Not dvList Is Nothing AndAlso dvList.Count > 0 Then
                    Dim columns As DataColumnCollection = dvList.ToTable().Columns

                    'Add First Item
                    If columns.Contains("FirstItemText") AndAlso Not IsDBNull(dvList(0)("FirstItemText")) Then
                        '.Items.Add(New ListItem(dvList(0)("FirstItemText").ToString()))
                    End If

                    If columns.Contains("AllowAddNewItemUserSetting") AndAlso Not String.IsNullOrEmpty(dvList(0)("AllowAddNewItemUserSetting")) AndAlso CBool(dvList(0)("AllowAddNewItemUserSetting")) = True Then bAllowAddNewItem = True

                Else
                    bAllowAddNewItem = True 'If the list is EMPTY, let the user add the first item irrespective of bAllowAddNewItem
                End If
            End With
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occurred while creating new procedure.", ex)
        End Try
    End Sub

    Public Shared Sub LoadRadioButtonList(ByVal radcbo As RadioButtonList,
                                   ByVal dtVals As DataTable,
                                   ByVal textField As String,
                                   ByVal valueField As String,
                                   Optional dataBind As Boolean = True)
        With radcbo
            .Items.Clear()
            .DataSource = dtVals
            .DataTextField = textField
            .DataValueField = valueField
            'DevNote: Avoid doing DataBind() when the RadComboBox is within RadGrrid's FilterTemplate. 
            'Otherwise duplicates will be inserted!!! Probably a Telerik bug.
            If dataBind Then
                .DataBind()
            End If
        End With
    End Sub

    '19 Mar 2021 : Mahfuz added to get Enumerator's values
    Public Shared Function GetEnumValues(Of T)() As List(Of T)
        Dim type = GetType(T)
        If Not type.IsSubclassOf(GetType(System.[Enum])) Then
            Throw New InvalidCastException($"Unable to cast '{type.FullName}' to System.Enum")
        End If
        Dim result = New List(Of T)
        For Each value As T In System.[Enum].GetValues(type)
            result.Add(value)
        Next
        Return result
    End Function
    Public Shared Function StripTags(ByVal html As String) As String
        ' Remove HTML tags.
        Return Regex.Replace(html, "<.*?>", "").Replace("&nbsp;", " ").Replace("  ", " ")
    End Function
    Public Shared Sub LoadCheckBoxList(ByVal radcbo As CheckBoxList,
                                   ByVal dtVals As DataTable,
                                   ByVal textField As String,
                                   ByVal valueField As String,
                                   Optional dataBind As Boolean = True)
        With radcbo
            .Items.Clear()
            .DataSource = dtVals
            .DataTextField = textField
            .DataValueField = valueField
            'DevNote: Avoid doing DataBind() when the RadComboBox is within RadGrrid's FilterTemplate. 
            'Otherwise duplicates will be inserted!!! Probably a Telerik bug.
            If dataBind Then
                .DataBind()
            End If
        End With
    End Sub

    Public Shared Sub SetNotificationStyle(ByRef notification As RadNotification, Optional text As String = "Record saved successfully.", Optional ByVal isError As Boolean = False, Optional title As String = "")
        With notification
            .Skin = "Metro"
            .BorderStyle = BorderStyle.Ridge
            If isError Then .BorderColor = Color.Red
            If Not isError Then .AutoCloseDelay = "3000" Else .AutoCloseDelay = 0
            .KeepOnMouseOver = False
            .Animation = NotificationAnimation.Fade
            .AnimationDuration = "100"
            .EnableRoundedCorners = False
            .EnableShadow = False
            If Not String.IsNullOrEmpty(title) Then
                .Title = title
            Else
                .Title = "HD Clinical Support Helpdesk: " & ConfigurationManager.AppSettings("Unisoft.Helpdesk")
            End If
            .Width = "375"
            .Height = "120"
            .Text = text
            .TitleIcon = "none"
            .ContentIcon = If(isError, "warning", "ok")
            .Position = NotificationPosition.Center
            .ShowCloseButton = True
        End With
    End Sub

    Public Shared Sub SetErrorNotificationStyle(ByRef notification As RadNotification,
                                                ByVal errorLogRef As String,
                                                Optional text As String = "There is a problem performing the task.")
        With notification
            .Skin = "Metro"
            .BorderColor = Color.Red
            .AutoCloseDelay = 0
            .BorderStyle = BorderStyle.Ridge
            .Animation = NotificationAnimation.None
            .EnableRoundedCorners = True
            .EnableShadow = True
            .Title = "HD Clinical Support Helpdesk: " & ConfigurationManager.AppSettings("Unisoft.Helpdesk")
            .Width = "400"
            .Height = "0"
            .Text = BuildFriendlyMessage(errorLogRef, text)
            .TitleIcon = "none"
            .ContentIcon = "warning"
            .Position = NotificationPosition.Center
            .ShowCloseButton = True
        End With
    End Sub

    Public Shared Function BuildFriendlyMessage(ByVal errorLogRef As String, ByVal text As String) As String
        Dim err As New StringBuilder
        err.Append("<table>")
        err.Append(String.Format("<tr><td colspan='2' class='aspxValidationSummaryHeader'>{0}</td></tr>", text))
        err.Append("<tr><td><br/></td></tr>")
        err.Append(String.Format("<tr><td colspan='2'>{0}</td></tr>", "Please contact HD Clinical Helpdesk with the following details."))
        If errorLogRef <> "" Then
            err.Append(String.Format("<tr><td style='width:100px'>{0}</td><td>{1}</td></tr>", "Error Reference:", errorLogRef))
        End If
        If HttpContext.Current.Session(Constants.SESSION_PROCEDURE_ID) Then
            err.Append(String.Format("<tr><td>{0}</td><td>{1}</td></tr>", "Procedure Id:", CStr(HttpContext.Current.Session(Constants.SESSION_PROCEDURE_ID))))
        End If
        err.Append("</table>")
        Return err.ToString
    End Function

    Public Shared Function GetInt(ByVal strVal As String) As Nullable(Of Integer)
        If Not String.IsNullOrEmpty(strVal) Then
            Dim retVal As Integer
            If Integer.TryParse(strVal, retVal) Then
                Return retVal
            Else
                Return Nothing
            End If
        Else
            Return Nothing
        End If
    End Function

    Public Shared Function GetPasswordASC(ByRef thePassword As String) As String
        Dim y As Long

        thePassword = UCase(thePassword)

        For x As Long = 1 To Len(thePassword)
            y = y + Asc(Mid(thePassword, x)) * x
        Next

        Return y
    End Function

    Public Shared Function GetRadioValue(ByVal rdo As RadioButtonList) As Integer
        If rdo.SelectedIndex = -1 Then
            Return 0
        Else
            Return CInt(rdo.SelectedValue)
        End If
    End Function

    Public Shared Function GetComboBoxValue(ByVal cbo As RadComboBox,
                                            Optional ByVal allowNulls As Boolean = False) _
                                        As Nullable(Of Integer)
        If cbo.SelectedValue = "" Then
            If allowNulls Then
                Return Nothing
            Else
                Return 0
            End If
        Else
            Return CInt(cbo.SelectedValue)
        End If
    End Function

    Public Shared Function GetComboBoxText(ByVal cbo As RadComboBox) As String

        If cbo Is Nothing Then
            Return ""
        ElseIf cbo.SelectedItem Is Nothing Then
            Return ""
        Else
            Return cbo.SelectedItem.Text
        End If

    End Function

    Public Shared Function GetDropDownListValue(ByVal drp As RadDropDownList,
                                                Optional ByVal allowNulls As Boolean = False) _
                                                As Nullable(Of Integer)
        If drp.SelectedValue = "" Then
            If allowNulls Then
                Return Nothing
            Else
                Return 0
            End If
        Else
            Return CInt(drp.SelectedValue)
        End If
    End Function

    Public Shared Function GetNumericTextBoxValue(ByVal numtxt As RadNumericTextBox, Optional ByVal sendNull As Boolean = False) As Nullable(Of Decimal)
        If Not numtxt.Value.HasValue Then
            If Not sendNull Then
                Return 0
            Else
                Return Nothing
            End If
        End If

        Return CDec(numtxt.Value)
    End Function

    Public Shared Function GetDecimalTextBoxValue(ByVal numtxt As RadTextBox) As Nullable(Of Decimal)
        If numtxt.Text.Trim() = "" Then
            Return Nothing
        End If

        Return CDec(numtxt.Text)
    End Function

    Public Shared Function GetHostName() As String
        'Dim test As New StringBuilder
        'For Each gogo In HttpContext.Current.Request.ServerVariables
        '    test.Append(gogo)
        '    test.Append(":")
        '    test.Append(HttpContext.Current.Request.ServerVariables(gogo))
        'Next
        'Return test.ToString()

        Try
            'Return System.Net.Dns.GetHostEntry("::1").HostName
            'Return System.Net.Dns.GetHostEntry("10.0.7.254").HostName
            'My.Computer.Name
            'Return System.Web.HttpContext.Current.Request.ServerVariables("remote_addr")
            If HttpContext.Current.Session("RoomName") Is Nothing Then
                'Dim fullName As String = System.Net.Dns.GetHostEntry(System.Web.HttpContext.Current.Request.ServerVariables("remote_addr")).HostName
                'HttpContext.Current.Session("PCName") = System.Net.Dns.GetHostEntry(HttpContext.Current.Request.ServerVariables("REMOTE_HOST").ToString).HostName.Trim
            End If
            Return CStr(HttpContext.Current.Session("RoomName")) 'fullName.Split(".")(0)
        Catch ex As Exception
            If TypeOf ex Is System.Net.Sockets.SocketException Then
                'Return "SocketException: " & ex.Message
                'TODO - RESEARCH IF THE PROPER MACHINE NAME CAN BE ATTAINED WHEN TRIED FROM OUT OF NETWORK.
                'THIS IS NOT VERY IMPORTANT AT THIS POINT OF TIME - Hence the dummy name.
                Return "External PC"
            Else
                Throw ex
            End If
        End Try
        Return ""
    End Function

    Public Shared Function GetHostFullName() As String
        Try
            'Return ""
            'Return System.Net.Dns.GetHostEntry("10.0.7.254").HostName
            Return System.Net.Dns.GetHostEntry(System.Web.HttpContext.Current.Request.ServerVariables("remote_addr")).HostName
        Catch ex As Exception
            If TypeOf ex Is System.Net.Sockets.SocketException Then
                'Return "SocketException: " & ex.Message
                'TODO - RESEARCH IF THE PROPER MACHINE NAME CAN BE ATTAINED WHEN TRIED FROM OUT OF NETWORK.
                'THIS IS NOT VERY IMPORTANT AT THIS POINT OF TIME - Hence the dummy name.
                Return "External PC"
            Else
                Throw ex
            End If
        End Try
        Return ""
    End Function

    Public Shared Function FixString(ByRef sString As String) As String
        FixString = Replace(sString, "'", "''")
    End Function

    Public Shared Function GetIPAddress() As String
        Dim context As System.Web.HttpContext = System.Web.HttpContext.Current
        Dim sIPAddress As String = context.Request.ServerVariables("HTTP_X_FORWARDED_FOR")
        If String.IsNullOrEmpty(sIPAddress) Then
            Return context.Request.ServerVariables("REMOTE_ADDR")
        Else
            Dim ipArray As String() = sIPAddress.Split(New [Char]() {","c})
            Return ipArray(0)
        End If
    End Function
    'Mahfuz copied and convereted from from HDC.Solus.Business.Core\Extensions.cs
    '24 June 2021
    Public Shared Function ValidateNHSNo(ByVal strNHSNumber As String) As Boolean
        If strNHSNumber Is Nothing Then Return False
        Dim temp As String = strNHSNumber.Replace(" ", String.Empty)
        If temp.Length <> 10 Then Return False
        Dim intTemp As Long
        If Not Long.TryParse(temp, intTemp) Then Return False
        Dim total As Integer = 0

        Try

            For i As Integer = 0 To 9

                Select Case i
                    Case 0
                        total += Integer.Parse(temp.Substring(i, 1)) * 10
                    Case 1
                        total += Integer.Parse(temp.Substring(i, 1)) * 9
                    Case 2
                        total += Integer.Parse(temp.Substring(i, 1)) * 8
                    Case 3
                        total += Integer.Parse(temp.Substring(i, 1)) * 7
                    Case 4
                        total += Integer.Parse(temp.Substring(i, 1)) * 6
                    Case 5
                        total += Integer.Parse(temp.Substring(i, 1)) * 5
                    Case 6
                        total += Integer.Parse(temp.Substring(i, 1)) * 4
                    Case 7
                        total += Integer.Parse(temp.Substring(i, 1)) * 3
                    Case 8
                        total += Integer.Parse(temp.Substring(i, 1)) * 2
                    Case 9
                        total += Integer.Parse(temp.Substring(i, 1)) * 1
                End Select
            Next

        Catch
            Return False
        End Try

        Dim remainder As Integer
        remainder = total Mod 11
        Dim check As Integer
        check = 11 - remainder
        If check = 0 OrElse check = 11 Then Return True
        Return False
    End Function
    Public Shared Function FormatHealthServiceNumber(healthServiceNo As String) As String
        Dim retHealthServiceNum As String = healthServiceNo
        Try
            If Not String.IsNullOrWhiteSpace(healthServiceNo) Then
                healthServiceNo = healthServiceNo.Replace(" ", "")
                Select Case HttpContext.Current.Session("CountryOfOriginHealthService")
                    Case "NHS"
                        retHealthServiceNum = healthServiceNo.Substring(0, 3) & " " & healthServiceNo.Substring(3, 3) & " " & healthServiceNo.Substring(6)
                    Case Else
                        Return retHealthServiceNum
                End Select
            End If
        Catch ex As Exception
        End Try
        Return retHealthServiceNum
    End Function
    Public Shared Function InstanceCount(ByVal StringToSearch As String,
                       ByVal StringToFind As String) As Long
        If Len(StringToFind) Then
            InstanceCount = UBound(Split(StringToSearch, StringToFind))
        End If
    End Function

    Public Shared Function GetAgeAtDate(birthdate As DateTime, asOfDate As DateTime) As String
        Dim age As Integer = asOfDate.Year - birthdate.Year
        If birthdate > asOfDate.AddYears(-age) Then
            age = age - 1
        End If
        Return CStr(age)
    End Function

End Class
