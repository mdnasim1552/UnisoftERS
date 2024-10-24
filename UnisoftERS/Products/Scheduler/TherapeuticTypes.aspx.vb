Public Class TherapeuticTypes
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            If String.IsNullOrWhiteSpace(Request.QueryString("ProcedureTypeID")) Then Exit Sub

            Page.Title = "Define " & Request.QueryString("ProcedureType").ToString() & " therapeutic types"
            Dim procType As ProcedureType = CInt(Request.QueryString("ProcedureTypeID").ToString())
            displayTherapeuticTypes(procType)
        End If
    End Sub

    Private Sub displayTherapeuticTypes(procType As ProcedureType)
        Dim da As New DataAccess_Sch
        TherapeuticTypesCheckBoxList.DataSource = da.GetTherapeuticTypes(procType)
        TherapeuticTypesCheckBoxList.DataTextField = "Description"
        TherapeuticTypesCheckBoxList.DataValueField = "Id"
        TherapeuticTypesCheckBoxList.DataBind()
    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs)
        Dim lst As New List(Of Integer)
        For Each itm As ListItem In TherapeuticTypesCheckBoxList.Items
            If itm.Selected Then
                lst.Add(itm.Value)
            End If
        Next

        Session("TherapeuticTypes_" & Request.QueryString("ProcedureTypeID").ToString()) = lst
        ScriptManager.RegisterStartupScript(Page, Page.GetType(), "closeTherapeuticTypesWindow", "CloseWindow();", True)
    End Sub

    Protected Sub TherapeuticTypesCheckBoxList_DataBound(sender As Object, e As EventArgs)
        If Session("TherapeuticTypes_" & Request.QueryString("ProcedureTypeID").ToString()) IsNot Nothing Then
            For Each item As ListItem In TherapeuticTypesCheckBoxList.Items
                Dim therapeuticTypeID As Integer = item.Value
                If CType(Session("TherapeuticTypes_" & Request.QueryString("ProcedureTypeID").ToString()), List(Of Integer)).Contains(therapeuticTypeID) Then
                    item.Selected = True
                End If
            Next
        End If
    End Sub
End Class