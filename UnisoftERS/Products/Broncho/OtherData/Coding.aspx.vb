Imports Telerik.Web.UI

Public Class Products_Broncho_OtherData_Coding
    Inherits PageBase

    Private procType As Integer

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        procType = IInt(Session(Constants.SESSION_PROCEDURE_TYPE))

        If Not Page.IsPostBack Then
            BindRepeaters()
        End If
    End Sub

    Private Sub BindRepeaters()
        Dim da As New OtherData
        Dim dtData As DataTable

        dtData = da.GetBronchoCoding(IInt(Session(Constants.SESSION_PROCEDURE_ID)), BronchoCodeSection.Diagnosis)
        DiagnosisRepeater.DataSource = dtData
        DiagnosisRepeater.DataBind()

        dtData = da.GetBronchoCoding(IInt(Session(Constants.SESSION_PROCEDURE_ID)), BronchoCodeSection.Therapeutic)
        TherapeuticRepeater.DataSource = dtData
        TherapeuticRepeater.DataBind()

        If procType = ProcedureType.EBUS Then
            Dim rootTab As RadTab = RadTabStrip1.FindTabByValue(2)
            rootTab.Visible = True
            EbusRepeater.Visible = True

            dtData = da.GetBronchoCoding(IInt(Session(Constants.SESSION_PROCEDURE_ID)), BronchoCodeSection.EbusLymphNodes)
            EbusRepeater.DataSource = dtData
            EbusRepeater.DataBind()
        Else

            Dim rootTab As RadTab = RadTabStrip1.FindTabByValue(2)
            rootTab.Visible = False
            EbusRepeater.Visible = False
        End If
    End Sub

    Protected Sub CancelButton_Click(sender As Object, e As EventArgs) Handles CancelButton.Click
        ExitForm()
    End Sub

    Sub ExitForm()
        Response.Redirect("~/Products/PatientProcedure.aspx", False)
    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        Dim da As New OtherData
        Dim fibreOpticSelected As Nullable(Of Boolean)
        Dim rigidSelected As Nullable(Of Boolean)
        Dim codeId As Integer
        Dim fibreOpticCheckBox As CheckBox
        Dim rigidCheckBox As CheckBox
        Dim codeIdHiddenField As HiddenField

        Try
            Dim repeaters As New List(Of Repeater)

            repeaters.Add(DiagnosisRepeater)
            repeaters.Add(TherapeuticRepeater)
            If procType = ProcedureType.EBUS Then
                repeaters.Add(EbusRepeater)
            End If

            For Each repeater In repeaters
                For Each item As RepeaterItem In repeater.Items
                    fibreOpticSelected = Nothing
                    rigidSelected = Nothing
                    fibreOpticCheckBox = TryCast(item.FindControl("FibreOpticCheckBox"), CheckBox)
                    rigidCheckBox = TryCast(item.FindControl("RigidCheckBox"), CheckBox)
                    codeIdHiddenField = TryCast(item.FindControl("CodeIdHiddenField"), HiddenField)

                    codeId = CInt(codeIdHiddenField.Value)

                    If fibreOpticCheckBox IsNot Nothing Then
                        fibreOpticSelected = fibreOpticCheckBox.Checked
                    End If

                    If rigidCheckBox IsNot Nothing Then
                        rigidSelected = rigidCheckBox.Checked
                    End If

                    da.SaveBronchoCoding(IInt(Session(Constants.SESSION_PROCEDURE_ID)), codeId, fibreOpticSelected, rigidSelected)
                Next
            Next

            BindRepeaters()

            ExitForm()

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occurred while saving Bronchoscopy Drugs.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub

    Private Sub DiagnosisRepeater_ItemDataBound(sender As Object, e As RepeaterItemEventArgs) Handles DiagnosisRepeater.ItemDataBound
        HideControl(e.Item, DirectCast(e.Item.DataItem, DataRowView))
    End Sub

    Private Sub TherapeuticRepeater_ItemDataBound(sender As Object, e As RepeaterItemEventArgs) Handles TherapeuticRepeater.ItemDataBound
        HideControl(e.Item, DirectCast(e.Item.DataItem, DataRowView))
    End Sub

    Private Sub EbusRepeater_ItemDataBound(sender As Object, e As RepeaterItemEventArgs) Handles EbusRepeater.ItemDataBound
        HideControl(e.Item, DirectCast(e.Item.DataItem, DataRowView))
    End Sub

    Private Sub HideControl(ri As RepeaterItem, dr As DataRowView)
        If (ri.ItemType = ListItemType.Item) OrElse (ri.ItemType = ListItemType.AlternatingItem) Then
            Dim FibreOpticCheckBox As CheckBox = TryCast(ri.FindControl("FibreOpticCheckBox"), CheckBox)
            Dim RigidCheckBox As CheckBox = TryCast(ri.FindControl("RigidCheckBox"), CheckBox)

            If IsDBNull(dr("FibreOpticCode")) OrElse CStr(dr("FibreOpticCode")) = "" Then
                If FibreOpticCheckBox IsNot Nothing Then
                    FibreOpticCheckBox.Visible = False
                End If
            End If

            If IsDBNull(dr("RigidCode")) OrElse CStr(dr("RigidCode")) = "" Then
                If RigidCheckBox IsNot Nothing Then
                    RigidCheckBox.Visible = False
                End If
            End If
        End If
    End Sub
End Class