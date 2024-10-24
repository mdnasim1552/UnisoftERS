Imports System.Drawing
Imports System.Web.DynamicData
Imports DevExpress.Data.Helpers
Imports Hl7.Fhir.Model
Imports Microsoft.Ajax.Utilities
Imports Telerik.Web.UI
Imports Telerik.Web.UI.Skins
Imports UnisoftERS.BusinessLogic


Partial Class Products_Common_WordLibrary
    Inherits OptionsBase
    Public Shared reqOption As String
    Public procType
    Public GeneralLibrary
    Private Shared procTypeId As Integer
    Protected Sub sPage_Load(sender As Object, e As EventArgs) Handles Me.Load

        If Not Page.IsPostBack Then
            RadNotification1.Title = "HD Clinical Support Helpdesk: " & ConfigurationManager.AppSettings("Unisoft.Helpdesk")
            OperatingHospitalsRadComboBox.DataSource = DataAdapter.GetOperatingHospitals()
            OperatingHospitalsRadComboBox.DataTextField = "HospitalName"
            OperatingHospitalsRadComboBox.DataValueField = "OperatingHospitalId"
            OperatingHospitalsRadComboBox.DataBind()
            OperatingHospitalsRadComboBox.SelectedValue = CInt(Session("OperatingHospitalId"))
            PhraseSearchHiddenField.Value = ""
            ProcedureTreeView()
            reqOption = Request.QueryString("option")
            Dim phraseList As Dictionary(Of String, String) = GetPhraseCategoryList()
            If reqOption = "NPSAAlert" Then
                Dim thera As New Therapeutics
                alerttextbox.Text = thera.GetNPSAalert(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
                opsHidden.Value = "NPSAAlert"
                SaveAlertButton.Text = "OK"
                SaveAlertButton.Icon.PrimaryIconCssClass = "telerikOkButton"
                divTitle.Visible = False
                GeneralPageView.Height = 120
                GeneralListBox.Height = 120
                GeneralListBox.Width = 510
                PersonalPageView.Height = 120
                PersonalListBox.Height = 120
                PersonalListBox.Width = 510
                alerttextbox.Height = 90
                alerttextbox.Width = 510
                tdTabStrip.Style("width") = "510px"
                tdArrows.Style("padding-left") = "95px"
                lblAlert.Text = "NPSA Alert"
            ElseIf reqOption = "SystemSettings" Then
                SaveAlertButton.Visible = False
                CloseAlertButton.Visible = False
                procedureColumn.Style("display") = ""
                PhraseCategory.Style("display") = ""
            Else
                For Each phraseType As KeyValuePair(Of String, String) In phraseList
                    If phraseType.Key = reqOption Then
                        Dim msgOption As String = Request.QueryString("msg")
                        If Not IsNothing(msgOption) Then alerttextbox.Text = HttpUtility.HtmlEncode(msgOption)
                        opsHidden.Value = phraseType.Key
                        lblAlert.Text = phraseType.Value
                        divTitle.Visible = False
                        Exit For
                    End If
                Next
            End If


            If Session("GeneralLibrary") = False Then
                ButtonDisableEnable(False)
            End If
        End If

        procType = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))
        If procedureColumn.Style("display") = "none" Then
            SelectedNodeValueHiddenField.Value = procType
        End If
        AddHandler ProcedureList.NodeClick, AddressOf ProcedureList_NodeClick
    End Sub


    Protected Sub ButtonDisableEnable(status As String)
        CopyToLibraryButton.Enabled = status
        EditRadLinkButton.Enabled = status
        DeleteRadLinkButton.Enabled = status
    End Sub

    Protected Function GetPhraseCategoryList() As Dictionary(Of String, String)
        Dim phraseCategoryList As New Dictionary(Of String, String)
        phraseCategoryList.Add("NPSAAlert", "NPSA Alert")
        phraseCategoryList.Add("CancerScreening", "Cancer Screening")
        phraseCategoryList.Add("FurtherProc", "Further procedure(s)")
        phraseCategoryList.Add("FollowUp", "Follow up")
        phraseCategoryList.Add("CommentRep", "Advice/comments (are printed at the end of the report)")
        phraseCategoryList.Add("PathFurtherProc", "Further procedure(s)")
        phraseCategoryList.Add("PathFollowUp", "Follow up")
        phraseCategoryList.Add("PathCommentRep", "Advice/comments (are printed at the end of the report)")
        phraseCategoryList.Add("FriendlyRep", "Advice/comments for patient friendly report")
        Return phraseCategoryList
    End Function

    Protected Sub DropDownList_SelectedIndexChanged(ByVal sender As Object, ByVal e As EventArgs)
        Dim nodeValue = procTypeId
        If ProcedureList.SelectedNode IsNot Nothing Then
            nodeValue = ProcedureList.SelectedNode.Value
        End If
        If nodeValue = procTypeId Then
            Dim radioButtonId As String = PhraseCategoryDropDown.SelectedValue
            ShowCloseIcon()
            opsHidden.Value = radioButtonId
            PhraseSearchBox.Text = ""
            PhraseSearchHiddenField.Value = ""
            CheckAlertTabStrip()
        End If
    End Sub

    Protected Sub ShowCloseIcon()
        Dim selectedNode As RadTreeNode = ProcedureList.SelectedNode
        If selectedNode IsNot Nothing Then
            Dim prefix As String = If(selectedNode.Nodes.Count > 0, "parent_", "child_")
            Dim script As String = "$('.procedureIcon').hide();" & "$('#" & prefix & procTypeId & "').show();"
            ScriptManager.RegisterStartupScript(Me, [GetType](), "ShowHideProcedureIcons", script, True)
        End If
    End Sub

    Protected Sub Window_open(sender As Object, e As EventArgs)
        Dim phraseText As String
        If GeneralListBox.SelectedItem IsNot Nothing Then
            phraseText = GeneralListBox.SelectedItem.Text
        ElseIf PersonalListBox.SelectedItem IsNot Nothing Then
            phraseText = PersonalListBox.SelectedItem.Text
        End If
        If Not IsNothing(phraseText) Then
            Dim cleanPhraseText = Replace(phraseText, vbLf, "\n")
            Dim encodedText = HttpUtility.UrlEncode(cleanPhraseText)
            Dim title = "Edit"
            Dim script As String = "var win = radopen('Prompt.aspx?phraseText=" & encodedText & "', ''); win.SetSize(645, 208); win.SetTitle('" & title & "'); win.center()"
            ScriptManager.RegisterStartupScript(Me, [GetType](), "", script, True)
        Else
            RadNotification1.Show("Please select a Phrase")
        End If
        ShowCloseIcon()
    End Sub

    Protected Sub PhraseSearchBox_TextChanged(sender As Object, e As EventArgs)
        PhraseSearchHiddenField.Value = PhraseSearchBox.Text.Trim()
        CheckAlertTabStrip()
        ShowCloseIcon()
    End Sub

    Protected Sub Get_AllData(sender As Object, e As EventArgs)
        PhraseCategoryDropDown.SelectedValue = ""

        If ProcedureList.SelectedNode IsNot Nothing Then
            ProcedureList.SelectedNode.Selected = False
        End If
        opsHidden.Value = ""
        PhraseSearchBox.Text = ""
        PhraseSearchHiddenField.Value = ""
        SelectedNodeValueHiddenField.Value = Nothing
        alerttextbox.Text = ""
        CheckAlertTabStrip()
    End Sub

    Protected Sub CheckAlertTabStrip()
        If (AlertTabStrip.SelectedIndex = 0) Then
            GeneralListBox.DataBind()
        Else
            PersonalListBox.DataBind()
        End If
    End Sub

    Protected Sub ProcedureTreeView()
        Dim db As New DataAccess
        Dim ProcedureTable As DataTable = db.GetDataFromStoredProcedure()
        Dim ProcedureIconText = "src='../../Images/Err-32x32.png'  class= 'procedureIcon'   onclick='showImage(event)' "
        For Each row As DataRow In ProcedureTable.Rows
            Dim parentNodeText As String = row("ParentNode").ToString()
            Dim childNodeText As String = row("ChildNode").ToString()

            Dim procedureTypeId As String = row("ProcedureTypeId").ToString()
            Dim parentId As String = row("ParentId").ToString()

            Dim parentText As String = parentNodeText & "<img id='parent_" & parentId & "'" & ProcedureIconText & "/>"
            Dim parentNode As RadTreeNode = ProcedureList.FindNodeByText(parentText)
            If parentNode Is Nothing Then
                parentNode = New RadTreeNode(parentText, parentId)
                ProcedureList.Nodes.Add(parentNode)
            End If
            Dim childNodeTextWithSpan As String = childNodeText & "<img id='child_" & procedureTypeId & "'" & ProcedureIconText & "/>"
            Dim childNode As New RadTreeNode(childNodeTextWithSpan, procedureTypeId)
            parentNode.Nodes.Add(childNode)
        Next
        ProcedureList.ExpandAllNodes()
    End Sub

    Private Sub ProcedureList_NodeClick(sender As Object, e As RadTreeNodeEventArgs)
        Dim ProcedureID As Integer = Convert.ToInt32(e.Node.Value)
        procTypeId = ProcedureID
        If e.Node.Nodes.Count > 0 Then
            Dim childNodeValues As New List(Of Integer)()
            For Each childNode As RadTreeNode In e.Node.Nodes
                childNodeValues.Add(Convert.ToInt32(childNode.Value))
            Next
            SelectedNodeValueHiddenField.Value = String.Join(",", childNodeValues)
        Else
            SelectedNodeValueHiddenField.Value = ProcedureID.ToString()
        End If
        ShowCloseIcon()
        opsHidden.Value = ""
        PhraseSearchBox.Text = ""
        PhraseSearchHiddenField.Value = ""
        PhraseCategoryDropDown.SelectedValue = ""
        CheckAlertTabStrip()
    End Sub

    Protected Sub AlertTabStrip_TabClick(ByVal sender As Object, ByVal e As RadTabStripEventArgs)
        PhraseSearchBox.Text = ""
        PhraseSearchHiddenField.Value = ""
        PhraseCategoryDropDown.SelectedValue = ""
        If procedureColumn.Style("display") = "none" Then
            SelectedNodeValueHiddenField.Value = procType
        Else
            opsHidden.Value = ""
        End If
        If GeneralListBox.SelectedItem IsNot Nothing Then
            GeneralListBox.SelectedItem.Selected = False
        ElseIf PersonalListBox.SelectedItem IsNot Nothing Then

            PersonalListBox.SelectedItem.Selected = False
        End If
        If e.Tab Is GeneralTab Then
            If Session("GeneralLibrary") = False Then
                ButtonDisableEnable(False)
            End If
            GeneralListBox.DataBind()
        ElseIf e.Tab Is PersonalTab Then
            If Session("GeneralLibrary") = False Then
                ButtonDisableEnable(True)
            End If
            PersonalListBox.DataBind()
        End If
        ShowCloseIcon()
    End Sub

    Protected Sub saveNPSAalert()
        If reqOption = "NPSAAlert" Then
            Dim thera As New Therapeutics
            thera.SaveNPSAalert(CInt(Session(Constants.SESSION_PROCEDURE_ID)), alerttextbox.Text)
            ScriptManager.RegisterStartupScript(Me, Page.GetType, "Script", "Close();", True)
        Else
            ScriptManager.RegisterStartupScript(Me, Page.GetType, "Script", "updateANDclose( '" & alerttextbox.Text.Replace(vbCrLf, "\n").Replace("'", "\'") & "');", True)
        End If
    End Sub

    <System.Web.Services.WebMethod()>
    Public Shared Function AddTextToLibrary(userName As String, Category As String, Phrase As String, OperatingHospitalId As Integer, ProcedureTypeId As String) As String
        Try
            Dim db As New DataAccess
            Return db.InsertPhrase(userName, Category, Phrase, OperatingHospitalId, ProcedureTypeId)
        Catch ex As Exception
            'log error and return error reference
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while adding a phrase.", ex)
            Throw New Exception(Utilities.BuildFriendlyMessage(errorLogRef, "There was a problem performing the task"))
        End Try
    End Function

    <System.Web.Services.WebMethod()>
    Public Shared Function DeleteTextFromLibrary(PhraseID As String) As String
        Try
            Dim db As New DataAccess
            Return CStr(db.DeletePhrase(PhraseID))
        Catch ex As Exception
            'log error and return error reference
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while deleting a phrase.", ex)
            Throw New Exception(Utilities.BuildFriendlyMessage(errorLogRef, "There was a problem performing the task"))
        End Try
    End Function

    <System.Web.Services.WebMethod()>
    Public Shared Function EditTextFromLibrary(PhraseID As String, Phrase As String) As String
        Try
            Dim db As New DataAccess
            Return CStr(db.EditPhrase(PhraseID, Phrase))
        Catch ex As Exception
            'log error and return error reference
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while editing a phrase.", ex)
            Throw New Exception(Utilities.BuildFriendlyMessage(errorLogRef, "There was a problem performing the task"))
        End Try
    End Function

End Class
