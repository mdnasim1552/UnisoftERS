Public Class Coding
    Inherits System.Web.UI.UserControl
    Private procType As Integer

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        procType = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))

        If Not Page.IsPostBack Then
            loadCoding()
        End If
    End Sub

    Private Sub loadCoding()
        Try
            Dim da As New OtherData
            Dim dtData As DataTable

            dtData = da.GetBronchoCoding(CInt(Session(Constants.SESSION_PROCEDURE_ID)), BronchoCodeSection.Diagnosis)
            DiagnosisRepeater.DataSource = dtData
            DiagnosisRepeater.DataBind()

            dtData = da.GetBronchoCoding(CInt(Session(Constants.SESSION_PROCEDURE_ID)), BronchoCodeSection.Therapeutic)
            TherapeuticRepeater.DataSource = dtData
            TherapeuticRepeater.DataBind()

            If procType = ProcedureType.EBUS Then
                ebusDiv.Visible = True

                dtData = da.GetBronchoCoding(CInt(Session(Constants.SESSION_PROCEDURE_ID)), BronchoCodeSection.EbusLymphNodes)
                EbusRepeater.DataSource = dtData
                EbusRepeater.DataBind()
            Else
                ebusDiv.Visible = False
            End If

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while loading Bronchoscopy coding.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem loading data.")
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