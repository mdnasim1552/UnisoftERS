Imports System.IO
Imports DevExpress.XtraPrinting

Imports Telerik.Web.UI

Public Class LetterPrinting
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            StartDate.SelectedDate = DateTime.Now
            EndDate.SelectedDate = DateTime.Now
            PopulateTrustDropDownList(CInt(Session("TrustId")))
            PopulateHospitalDropDownList(CInt(Session("TrustId")))
            PopulateAppointmentStatusDropDownList()
            PopulateGrid()
        End If
    End Sub
    Protected Sub ViewAllCheckbox_CheckedChanged(sender As Object, e As EventArgs)
        PopulateGrid()
    End Sub


    Protected Sub PrintButton_Click(sender As Object, e As EventArgs)
        Try
            If LetterQueueGrid.MasterTableView.Items.Count > 0 Then
                Dim letterIdList As String = String.Empty

                For Each item As GridDataItem In LetterQueueGrid.MasterTableView.Items
                    If TryCast(item.FindControl("LetterQueueId"), CheckBox).Checked = True Then
                        Dim LetterQueueId = item.GetDataKeyValue("LetterQueueId").ToString()
                        Dim bAdditionalDocumentRequired = TryCast(item.FindControl("AdditionalDocument"), CheckBox).Checked
                        letterIdList = letterIdList & LetterQueueId & "*" & bAdditionalDocumentRequired & "-"
                    End If
                Next

                If Not String.IsNullOrEmpty(letterIdList) Then
                    letterIdList = letterIdList.TrimEnd(CChar("-"))

                    Dim url As String = "../Letters/DisplayAndPrintPDF.aspx?LetterQueueIds=" & letterIdList
                    Dim s As String = "window.open('" & url & "', '_blank');"
                    ScriptManager.RegisterStartupScript(Me.Page, Page.GetType(), "text", s, True)
                Else
                    If LetterQueueGrid.SelectedItems.Count > 0 Then
                        letterIdList = $"{LetterQueueGrid.MasterTableView.Items.Item(LetterQueueGrid.SelectedItems(0).ItemIndex).GetDataKeyValue("LetterQueueId").ToString()}*False"
                        Dim url As String = "../Letters/DisplayAndPrintPDF.aspx?LetterQueueIds=" & letterIdList
                        Dim s As String = "window.open('" & url & "', '_blank');"
                        ScriptManager.RegisterStartupScript(Me.Page, Page.GetType(), "text", s, True)
                    Else
                        ScriptManager.RegisterStartupScript(Me.Page, Page.GetType(), "text", "ShowNoSelectMessage()", True)
                    End If
                End If
            End If
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured During Printing.", ex)
            Utilities.SetErrorNotificationStyle(LetterPrintRadNotification, errorLogRef, "Error During Printing letter.")
            LetterPrintRadNotification.Show()
        End Try

    End Sub
    Protected Sub ClearWorkDirectory(directoryName As String)

        For Each deleteFile In Directory.GetFiles(directoryName, "*.*", SearchOption.TopDirectoryOnly)
            File.Delete(deleteFile)
        Next
    End Sub
    Private Sub PopulateHospitalDropDownList(TrustId As Integer)
        Dim da As New LetterGeneration
        HospitalDropDownList.Items.Clear()
        HospitalDropDownList.Items.Insert(0, New DropDownListItem("ALL", 0))
        HospitalDropDownList.AppendDataBoundItems = True
        HospitalDropDownList.DataSource = da.GetOperatingHospitals(TrustId)
        HospitalDropDownList.DataBind()
    End Sub
    Private Sub PopulateTrustDropDownList(TrustId As Integer)
        Dim da As New DataAccess
        TrustDropDownList.Items.Clear()
        TrustDropDownList.DataSource = da.GetTrusts()
        TrustDropDownList.DataBind()
        If Not TrustId = 0 Then
            TrustDropDownList.SelectedValue = TrustId
        End If
    End Sub

    Private Sub PopulateAppointmentStatusDropDownList()
        Dim da As New LetterGeneration
        AppointmentStatusDropDownList.Items.Clear()
        AppointmentStatusDropDownList.Items.Insert(0, New DropDownListItem("ALL", 0))
        AppointmentStatusDropDownList.AppendDataBoundItems = True
        AppointmentStatusDropDownList.DataSource = da.GetAppointmentStatusForPrinting()
        AppointmentStatusDropDownList.DataBind()
    End Sub
    Protected Sub CheckCreateAndClearDirectory(directoryName As String)

        If Directory.Exists(directoryName) Then
            ClearWorkDirectory(directoryName)
        Else
            Directory.CreateDirectory(directoryName)
        End If
    End Sub

    Protected Sub SearchButton_Click(sender As Object, e As EventArgs)
        PopulateGrid()
    End Sub

    Protected Sub LetterQueueGrid_ItemCommand(sender As Object, e As GridCommandEventArgs)

    End Sub

    Protected Sub LetterQueueGrid_ItemDataBound(sender As Object, e As GridItemEventArgs)
        'Dim da As New LetterGeneration
        'LetterQueueGrid.DataSource = da.GetLetterQueueList(StartDate.SelectedDate, EndDate.SelectedDate, 0, 0, 0)
        'LetterQueueGrid.DataBind()
    End Sub
    Protected Sub LetterQueueGrid_NeedDataSource(sender As Object, e As GridNeedDataSourceEventArgs)
        Dim da As New LetterGeneration
        LetterQueueGrid.DataSource = da.GetLetterQueueList(StartDate.SelectedDate, EndDate.SelectedDate, 0, 0, 0)
        'LetterQueueGrid.Rebind()

    End Sub

    Protected Sub AppointmentStatusDropDownList_SelectedIndexChanged(sender As Object, e As DropDownListEventArgs)


        PopulateGrid()


    End Sub

    Protected Sub HospitalDropDownList_SelectedIndexChanged(sender As Object, e As DropDownListEventArgs)
        PopulateGrid()
    End Sub
    Protected Sub TrustDropDownList_SelectedIndexChanged(sender As Object, e As DropDownListEventArgs)
        PopulateHospitalDropDownList(TrustDropDownList.SelectedValue)
        PopulateGrid()
    End Sub

    Protected Sub PopulateGrid()

        Dim isPrinted
        If ViewAllCheckbox.Checked Then
            isPrinted = 1
        Else
            isPrinted = 0
        End If
        Dim da As New LetterGeneration
        Dim hospitaIds As String
        If (HospitalDropDownList.SelectedValue = 0) Then
            Dim hospitaIdArr As New List(Of String)

            For Each item As DropDownListItem In HospitalDropDownList.Items
                hospitaIdArr.Add(item.Value)
            Next
            hospitaIds = String.Join(",", hospitaIdArr)
        Else
            hospitaIds = HospitalDropDownList.SelectedValue.ToString()
        End If

        LetterQueueGrid.DataSource = da.GetLetterQueueList(StartDate.SelectedDate, EndDate.SelectedDate, isPrinted, hospitaIds, AppointmentStatusDropDownList.SelectedValue, HospitalNumber.Text)
        LetterQueueGrid.DataBind()
    End Sub


    Protected Sub ToggleRowSelection(ByVal sender As Object, ByVal e As EventArgs)

        TryCast(TryCast(sender, CheckBox).NamingContainer, GridItem).Selected = TryCast(sender, CheckBox).Checked
        Dim checkHeader As Boolean = True
        For Each dataItem As GridDataItem In LetterQueueGrid.MasterTableView.Items
            If Not TryCast(dataItem.FindControl("LetterQueueId"), CheckBox).Checked Then
                checkHeader = False
                Exit For
            End If
        Next
        Dim headerItem As GridHeaderItem = TryCast(LetterQueueGrid.MasterTableView.GetItems(GridItemType.Header)(0), GridHeaderItem)
        TryCast(headerItem.FindControl("LetterQueueIdheaderChkbox"), CheckBox).Checked = checkHeader
    End Sub
    Protected Sub ToggleSelectedState(ByVal sender As Object, ByVal e As EventArgs)
        Dim headerCheckBox As CheckBox = TryCast(sender, CheckBox)
        For Each dataItem As GridDataItem In LetterQueueGrid.MasterTableView.Items
            TryCast(dataItem.FindControl("LetterQueueId"), CheckBox).Checked = headerCheckBox.Checked
            dataItem.Selected = headerCheckBox.Checked
        Next
    End Sub
    Protected Sub AdditionalDocsToggleRowSelection(ByVal sender As Object, ByVal e As EventArgs)

        TryCast(TryCast(sender, CheckBox).NamingContainer, GridItem).Selected = TryCast(sender, CheckBox).Checked
        Dim checkHeader As Boolean = True
        For Each dataItem As GridDataItem In LetterQueueGrid.MasterTableView.Items
            If Not TryCast(dataItem.FindControl("AdditionalDocument"), CheckBox).Checked Then
                checkHeader = False
                Exit For
            End If
        Next
        Dim headerItem As GridHeaderItem = TryCast(LetterQueueGrid.MasterTableView.GetItems(GridItemType.Header)(0), GridHeaderItem)
        TryCast(headerItem.FindControl("AdditionalDocumentheaderChkbox"), CheckBox).Checked = checkHeader
    End Sub
    Protected Sub AdditionalDocsToggleSelectedState(ByVal sender As Object, ByVal e As EventArgs)
        Dim headerCheckBox As CheckBox = TryCast(sender, CheckBox)
        For Each dataItem As GridDataItem In LetterQueueGrid.MasterTableView.Items
            TryCast(dataItem.FindControl("AdditionalDocument"), CheckBox).Checked = headerCheckBox.Checked
            dataItem.Selected = headerCheckBox.Checked
        Next
    End Sub

    Private Sub LetterPrinting_PreRender(sender As Object, e As EventArgs) Handles Me.PreRender
        Dim headerText = LetterQueueGrid.MasterTableView.GetColumn("NHSNo").HeaderText

        If headerText = "NHS no." Then
            LetterQueueGrid.MasterTableView.GetColumn("NHSNo").HeaderText = Session(Constants.SESSION_HEALTH_SERVICE_NAME).ToString().ToUpper() + " no."
            LetterQueueGrid.MasterTableView.Rebind()
        End If
    End Sub
End Class