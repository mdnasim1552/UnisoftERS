Public Class TherapeuticTypes
    Inherits OptionsBase

    ReadOnly Property Mode As String
        Get
            Return Request.QueryString("mode")
        End Get
    End Property

    ReadOnly Property EndoscopistId As Integer
        Get
            If String.IsNullOrWhiteSpace(Request.QueryString("EndoscopistId")) Then
                Return 0
            Else
                Return CInt(Request.QueryString("EndoscopistId"))
            End If
        End Get
    End Property

    Property ProcTypes As List(Of Integer)
        Get
            If Mode = "search" Then
                Return CType(Session("SearchTherapeuticTypes_" & Request.QueryString("ProcedureTypeID").ToString()), List(Of Integer))
            Else
                Return CType(Session("TherapeuticTypes_" & Request.QueryString("ProcedureTypeID").ToString()), List(Of Integer))
            End If
        End Get
        Set(value As List(Of Integer))
            If Mode = "search" Then
                Session("SearchTherapeuticTypes_" & Request.QueryString("ProcedureTypeID")) = value
            Else
                Session("TherapeuticTypes_" & Request.QueryString("ProcedureTypeID")) = value
            End If
        End Set
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            If Mode = "search" Then Session("TherapeuticTypes_" & Request.QueryString("ProcedureTypeID")) = Nothing 'clear out any previously set session for the OPOSITE mode to avoid confusion


            If String.IsNullOrWhiteSpace(Request.QueryString("ProcedureTypeID")) Then Exit Sub

            Page.Title = "Define " & Request.QueryString("ProcedureType").ToString() & " therapeutic types"
            Dim procType As Integer = CInt(Request.QueryString("ProcedureTypeID"))
            displayTherapeuticTypes(procType)
        End If
    End Sub

    Private Sub displayTherapeuticTypes(procedureTypeId As Integer)
        Dim da As New DataAccess_Sch
        'ProcTypes = Nothing
        Try
            If Mode Is Nothing AndAlso Session("SelectedEndoscopistId") IsNot Nothing And ProcTypes Is Nothing Then
                'Get the selected endoscopists therapeutic selections for the selected Procedure
                Dim UserId As Integer = Session("SelectedEndoscopistId")
                Dim lst As New List(Of Integer)
                Dim dt As New DataTable()

                dt = da.GetTherapeuticProcedures(procedureTypeId, UserId)
                For Each row In dt.Rows
                    lst.Add(row("TherapeuticTypeId"))
                Next
                ProcTypes = lst
            End If

            If procedureTypeId = 5 Then    'PROCT only has one therapeutic type
                ItemSelectorRadPane.Visible = False
            End If

            TherapeuticTypesCheckBoxList.DataSource = da.GetTherapeuticTypes(procedureTypeId)
            TherapeuticTypesCheckBoxList.DataTextField = "Description"
            TherapeuticTypesCheckBoxList.DataValueField = "Id"
            TherapeuticTypesCheckBoxList.DataBind()
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error in TherapeuticTypes.displayTherapeuticTypes", ex)
        End Try

    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs)
        Dim lst As New List(Of Integer)
        For Each itm As ListItem In TherapeuticTypesCheckBoxList.Items
            If itm.Selected Then
                lst.Add(itm.Value)
            End If
        Next

        ProcTypes = lst

        If Mode Is Nothing OrElse Not Mode = "search" Then
            Session("Page_Updated") = True
        End If

        ScriptManager.RegisterStartupScript(Page, Page.GetType(), "closeTherapeuticTypesWindow", "CloseWindow();", True)
    End Sub

    Protected Sub TherapeuticTypesCheckBoxList_DataBound(sender As Object, e As EventArgs)
        Try
            If ProcTypes IsNot Nothing Then
                For Each item As ListItem In TherapeuticTypesCheckBoxList.Items
                    Dim therapeuticTypeID As Integer = item.Value
                    If ProcTypes.Contains(therapeuticTypeID) Then
                        item.Selected = True
                    End If
                Next
            End If


        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error in TherapeuticTypes.TherapeuticTypesCheckBoxList_DataBound", ex)
        End Try
    End Sub

    Protected Sub ItemSelector_Click(sender As Object, e As EventArgs)
        If Session("ToggleSelection") Is Nothing Then
            Session("ToggleSelection") = True
        End If

        If Session("ToggleSelection") Then
            For Each item As ListItem In TherapeuticTypesCheckBoxList.Items
                If item.Enabled Then
                    item.Selected = True
                    Session("ToggleSelection") = False
                End If
            Next
        Else
            For Each item As ListItem In TherapeuticTypesCheckBoxList.Items
                If item.Enabled Then
                    item.Selected = False
                    Session("ToggleSelection") = True
                End If
            Next
        End If

    End Sub

    Protected Sub TherapeuticTypesCheckBoxList_PreRender(sender As Object, e As EventArgs)
        Try
            If Mode = "search" AndAlso EndoscopistId > 0 Then
                'get users therapeutics

                Dim da As New DataAccess_Sch
                Dim dt = da.GetTherapeuticProcedures(CInt(Request.QueryString("ProcedureTypeID").ToString()), EndoscopistId)
                Dim endoTherapeutics = (From t In dt.AsEnumerable
                                        Select CInt(t("TherapeuticTypeId"))).ToList

                For Each itm As ListItem In TherapeuticTypesCheckBoxList.Items
                    If Not endoTherapeutics.Contains(itm.Value) Then
                        itm.Enabled = False
                    End If
                Next
            End If
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("Error in enabling/disabling endoscopists therapeutics", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, ref, "We was unable to disable therapeutics not assigned to your selected endoscospist.")
            RadNotification1.Show()
        End Try
    End Sub
End Class