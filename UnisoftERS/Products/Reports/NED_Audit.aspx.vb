Public Class NEDReports
    Inherits OptionsBase

    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Init
        SqlDataSource1.ConnectionString = DataAccess.ConnectionStr

        If IsNothing(Session("PKUserID")) Then
            Response.Redirect("/", False)
        End If
    End Sub
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not (Page.IsPostBack) Then
            RadGridNED.Visible = False '### Initially hide it.. as it is confusingly showing a gray border while empty on form Load!

            '### Set here as setting in markup causes it to go back to the set date after postback
            RDPFrom.SelectedDate = "1980-01-01"
            RDPTo.SelectedDate = "2099-12-30"
        End If
    End Sub

    Protected Sub Go_Click(sender As Object, e As EventArgs) Handles Go.Click
        Try

        NedClass.FromDate = RDPFrom.SelectedDate.ToString
        NedClass.ToDate = RDPTo.SelectedDate.ToString
        NedClass.IsRejected = IsRejected.SelectedValue.ToString
        NedClass.IsSent = Me.IsSent.SelectedValue.ToString
        NedClass.ProcedureTypeId = ""

        If Not AllProcedureTypesCheckbox.Checked Then
            Dim selectedProcedures As String = ""

            For Each li As ListItem In chkProcedureType.Items
                'Dont include the 1st checkbox
                If li.Value = 0 Then Continue For

                If li.Selected Then
                    selectedProcedures += li.Value & "," 'append with comma as this with be using with the IN() operator
                End If
            Next

            'Remove last comma
            selectedProcedures = selectedProcedures.Remove(selectedProcedures.Length - 1)
            NedClass.ProcedureTypeId = selectedProcedures
        End If


        NedClass.PatientName = PatientName.Value
        NedClass.CNN = CNN.Value
        NedClass.NHS = NHS.Value
        RadGridNED.DataBind()
        RadGridNED.Visible = True
            
        Catch ex As Exception

        End Try
    End Sub
End Class