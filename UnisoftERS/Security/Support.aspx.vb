Imports Telerik.Web.UI
Imports System.Data.SqlClient

Partial Class Security_Support
    Inherits PageBase

    Protected Sub Page_Load(sender As Object, e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            InitForm()
        End If
    End Sub

    Private Sub InitForm()
        Me.Title = "Support"
    End Sub


    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        'Try
        '    Dim sql As New StringBuilder

        '    sql.Append("UPDATE CRM_Customers ")
        '    sql.Append("SET MaintenanceDue=@RenewalDate ")
        '    sql.Append("WHERE HospitalID=@HospitalID")

        '    Using connection As New SqlConnection(DataAccess.ConnectionStr)
        '        Dim cmd As New SqlCommand(sql.ToString(), connection)
        '        cmd.CommandType = CommandType.Text
        '        cmd.Parameters.Add(New SqlParameter("@HospitalID", CInt(Session("HospitalID"))))
        '        cmd.Parameters.Add(New SqlParameter("@RenewalDate", RenewalDatePicker.SelectedDate))
        '        connection.Open()
        '        cmd.ExecuteNonQuery()
        '        ExpiresOnDatePicker.SelectedDate = RenewalDatePicker.SelectedDate
        '    End Using


        '    Utilities.SetNotificationStyle(RadNotification1)
        '    RadNotification1.Show()

        'Catch ex As Exception
        '    Dim errorLogRef As String
        '    errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving renewal date.", ex)

        '    Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
        '    RadNotification1.Show()
        'End Try
    End Sub

End Class
