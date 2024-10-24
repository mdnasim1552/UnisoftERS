Imports Telerik.Web.UI

Partial Class Products_Options_EditDiagnoses
    Inherits OptionsBase

    Private newDiagId As Integer
    'Private editDiagId As Integer
    Shared DiagID As Int32

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsPostBack Then
            If Not String.IsNullOrEmpty(Request.QueryString("DiagID")) Then
                DiagID = CInt(Request.QueryString("DiagID"))
                HeadingLabel.Text = "Modify diagnoses"
                DiagObjectDataSource.SelectParameters("DiagnosesMatrixID").DefaultValue = DiagID
                DiagDetailsFormView.DefaultMode = FormViewMode.Edit
                DiagDetailsFormView.DataBind()
            Else
                HeadingLabel.Text = "Add new diagnoses"
                DiagDetailsFormView.DefaultMode = FormViewMode.Insert
            End If

        End If
    End Sub
    
    Protected Sub DiagDetailsFormView_Init(sender As Object, e As EventArgs) Handles DiagDetailsFormView.Init
        If Not IsPostBack Then
            DiagDetailsFormView.InsertItemTemplate = DiagDetailsFormView.EditItemTemplate
        End If
    End Sub

    Protected Sub DiagDetailsFormView_ItemCommand(sender As Object, e As FormViewCommandEventArgs) Handles DiagDetailsFormView.ItemCommand
        Try
        If e.CommandName = "InsertAndClose" Then
            DiagDetailsFormView.InsertItem(True)
            ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "Insert_CloseAndRebind", "CloseAndRebind('navigateToInserted');", True)
        ElseIf e.CommandName = "UpdateAndClose" Then
            DiagDetailsFormView.UpdateItem(True)
            ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "Update_CloseAndRebind", "CloseAndRebind();", True)
        End If
        Catch ex As Exception

        End Try

    End Sub

    Protected Sub DiagDetailsFormView_ItemInserted(sender As Object, e As FormViewInsertedEventArgs) Handles DiagDetailsFormView.ItemInserted
        If e.Exception Is Nothing Then
            Utilities.SetNotificationStyle(RadNotification1)
            RadNotification1.Show()
        Else
            Dim bex As Exception = e.Exception.GetBaseException()
            Dim errorLogRef As String = LogManager.LogManagerInstance.LogError("Error occured while adding new premdication Diag.", bex)

            e.ExceptionHandled = True
            e.KeepInInsertMode = True

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()

            'Clear Script
            ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "Insert_CloseAndRebind", "", True)
        End If
    End Sub

    Protected Sub DiagDetailsFormView_ItemInserting(sender As Object, e As FormViewInsertEventArgs) Handles DiagDetailsFormView.ItemInserting
        DiagObjectDataSource.InsertParameters("ProcedureTypeID").DefaultValue = CInt(Request.QueryString("Pnode"))
        DiagObjectDataSource.InsertParameters("Section").DefaultValue = Request.QueryString("Cnode")
    End Sub

    Protected Sub DiagDetailsFormView_ItemUpdated(sender As Object, e As FormViewUpdatedEventArgs) Handles DiagDetailsFormView.ItemUpdated
        If e.Exception Is Nothing Then
            Utilities.SetNotificationStyle(RadNotification1)
            RadNotification1.Show()
        Else
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving premedication Diag.", e.Exception)

            e.ExceptionHandled = True
            e.KeepInEditMode = True

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()

            'Clear Script
            ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "Update_CloseAndRebind", "", True)
        End If
    End Sub

    Protected Sub DiagDetailsFormView_Load(sender As Object, e As EventArgs) Handles DiagDetailsFormView.Load
        Dim SectionTextbox As TextBox = DirectCast(DiagDetailsFormView.FindControl("SectionTextbox"), TextBox)
        Dim LocationTextbox As TextBox = DirectCast(DiagDetailsFormView.FindControl("LocationTextbox"), TextBox)
        If Not IsNothing(SectionTextbox) Then SectionTextbox.Text = Request.QueryString("Pnode")
        If Not IsNothing(LocationTextbox) Then LocationTextbox.Text = Request.QueryString("Cnode")
    End Sub

    Protected Sub DiagDetailsFormView_PreRender(sender As Object, e As EventArgs) Handles DiagDetailsFormView.PreRender
        Dim SaveAndCloseButton As RadButton
        If DiagDetailsFormView.CurrentMode = FormViewMode.Edit Then
            SaveAndCloseButton = DirectCast(DiagDetailsFormView.FindControl("SaveAndCloseButton"), RadButton)
            If SaveAndCloseButton IsNot Nothing Then SaveAndCloseButton.CommandName = "UpdateAndClose"
            Dim rowView As DataRowView = CType(DiagDetailsFormView.DataItem, DataRowView)
        ElseIf DiagDetailsFormView.CurrentMode = FormViewMode.Insert Then
            SaveAndCloseButton = DirectCast(DiagDetailsFormView.FindControl("SaveAndCloseButton"), RadButton)
            If SaveAndCloseButton IsNot Nothing Then SaveAndCloseButton.CommandName = "InsertAndClose"
        End If
    End Sub

    Protected Sub DiagDetailsObjectDataSource_Inserted(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles DiagObjectDataSource.Inserted
        newDiagId = CInt(e.ReturnValue)
    End Sub
End Class
