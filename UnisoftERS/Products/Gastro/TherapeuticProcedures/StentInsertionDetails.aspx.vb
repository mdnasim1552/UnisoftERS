Imports Telerik.Web.UI

Public Class StentInsertionDetails
    Inherits System.Web.UI.Page

    Public ReadOnly Property sArea() As String
        Get
            Return Request.QueryString("area")
        End Get
    End Property

     Public ReadOnly Property iTherapeuticId() As String
        Get
            Return Request.QueryString("therapeuticId")
        End Get
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            'see if theres any insertion details in the DB and set to session
            LoadData()
        End If
    End Sub

    Private Sub LoadData()
        Dim rowQty = CInt(Request.QueryString("qty"))
        Dim dt As New DataTable
        dt.Columns.Add("InsertionType")
        dt.Columns.Add("InsertionLength")
        dt.Columns.Add("Dialation")
        dt.Columns.Add("DialatinUnits")

        For i As Integer = 0 To rowQty - 1
            Dim insertionType As Integer = -1
            Dim iInsertionLength = 0
            Dim iDialation = 0
            Dim sDialationUnits = 0

            'check for session and load from there if available
            If Session("StentInsertionDetails") IsNot Nothing AndAlso CType(Session("StentInsertionDetails"), List(Of StentInsertion)).Count > 0 Then
                Dim SIDetails = CType(Session("StentInsertionDetails"), List(Of StentInsertion))
                If SIDetails.Count > i Then
                    insertionType = SIDetails(i).StentInsertionType
                    iInsertionLength = SIDetails(i).StentInsertionLength
                    iDialation = SIDetails(i).StentInsertionDiameter
                    sDialationUnits = SIDetails(i).StentInsertionDiameterUnits
                End If
            End If

            Dim dr = dt.NewRow()
            dr("InsertionType") = insertionType
            dr("InsertionLength") = iInsertionLength
            dr("Dialation") = iDialation
            dr("DialatinUnits") = sDialationUnits
            dt.Rows.Add(dr)
        Next

        StentTypesRepeater.DataSource = dt
        StentTypesRepeater.DataBind()
    End Sub

    Protected Sub StentTypesRepeater_ItemDataBound(sender As Object, e As RepeaterItemEventArgs)
        If e.Item.DataItem Is Nothing Then Exit Sub

        Dim StentInsertionTypeComboBox As RadComboBox = e.Item.FindControl("StentInsertionTypeComboBox")
        Dim StentInsertionDiaUnitsComboBox As RadComboBox = e.Item.FindControl("StentInsertionDiaUnitsComboBox")
        Dim StentInsertionLengthNumericTextBox As RadNumericTextBox = e.Item.FindControl("StentInsertionLengthNumericTextBox")
        Dim StentInsertionDiaNumericTextBox As RadNumericTextBox = e.Item.FindControl("StentInsertionDiaNumericTextBox")

        Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {
                               {StentInsertionTypeComboBox, IIf(sArea <> "Stomach", "Therapeutic Stent Insertion Types", "Therapeutic Stomach Stent Insertion Types")},
                               {StentInsertionDiaUnitsComboBox, "Oesophageal dilatation units"}
                    })

        Dim dr = DirectCast(e.Item.DataItem, System.Data.DataRowView)
        If CInt(dr("InsertionType")) > -1 Then StentInsertionTypeComboBox.SelectedValue = CInt(dr("InsertionType"))
        If CInt(dr("InsertionType")) > -1 Then StentInsertionLengthNumericTextBox.Value = CInt(dr("InsertionLength"))
        If CInt(dr("InsertionType")) > -1 Then StentInsertionDiaNumericTextBox.Value = CInt(dr("Dialation"))
        If CInt(dr("InsertionType")) > -1 Then StentInsertionDiaUnitsComboBox.SelectedValue = CInt(dr("DialatinUnits"))
    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs)
        Try
            Dim insertionDetails As New List(Of StentInsertion)
            For Each item As RepeaterItem In StentTypesRepeater.Items
                Dim si As New StentInsertion
                With si
                    Dim StentInsertionTypeComboBox = CType(item.FindControl("StentInsertionTypeComboBox"), RadComboBox)

                    If StentInsertionTypeComboBox.SelectedIndex > 0 Then
                        If StentInsertionTypeComboBox.Text <> "" AndAlso StentInsertionTypeComboBox.SelectedValue = -99 Then
                            Dim da As New DataAccess
                            Dim newId = da.InsertListItem(IIf(sArea <> "Stomach", "Therapeutic Stent Insertion Types", "Therapeutic Stomach Stent Insertion Types"), StentInsertionTypeComboBox.Text)
                            If newId > 0 Then .StentInsertionType = newId
                        Else
                            .StentInsertionType = StentInsertionTypeComboBox.SelectedValue
                        End If

                        If CType(item.FindControl("StentInsertionLengthNumericTextBox"), RadNumericTextBox).Value IsNot Nothing Then .StentInsertionLength = CType(item.FindControl("StentInsertionLengthNumericTextBox"), RadNumericTextBox).Value
                        If CType(item.FindControl("StentInsertionDiaNumericTextBox"), RadNumericTextBox).Value IsNot Nothing Then .StentInsertionDiameter = CType(item.FindControl("StentInsertionDiaNumericTextBox"), RadNumericTextBox).Value
                        If CType(item.FindControl("StentInsertionDiaUnitsComboBox"), RadComboBox).SelectedIndex > 0 then .StentInsertionDiameterUnits = CType(item.FindControl("StentInsertionDiaUnitsComboBox"), RadComboBox).SelectedValue
                    End If
                End With

                insertionDetails.Add(si)
            Next

            Session("StentInsertionDetails") = insertionDetails
            ScriptManager.RegisterStartupScript(Me, Me.[GetType](), "CloseMe", "CloseWindow();", True)

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving ERCP Stent insertion details.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub
End Class