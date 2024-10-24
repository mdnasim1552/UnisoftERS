Public Class PatientNotes
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not IsPostBack Then
            PopulatePage()
        End If
    End Sub


    Private Sub PopulatePage()
        Dim da As DataAccess = New DataAccess()
        Dim dt As DataTable = da.GetPatientNotes(Session(Constants.SESSION_PROCEDURE_ID))
        If Not IsNothing(dt) AndAlso dt.Rows.Count > 0 Then
            PatientNotesTextBox.Text = Server.HtmlDecode(dt.Rows(0).Item("PatientNotes"))
            PatientHistoryTextBox.Text = Server.HtmlDecode(dt.Rows(0).Item("PatientHistory"))
        End If
    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        Dim da As DataAccess = New DataAccess()
        da.SavePatientNotes(Session(Constants.SESSION_PROCEDURE_ID), Server.HtmlEncode(PatientNotesTextBox.Text), Server.HtmlEncode(PatientHistoryTextBox.Text))
        ExitForm()

    End Sub

    Protected Sub CancelButton_Click(sender As Object, e As EventArgs) Handles CancelButton.Click
        ExitForm()
    End Sub

    Sub ExitForm()
        Response.Redirect("~/Products/PatientProcedure.aspx", False)
    End Sub
End Class