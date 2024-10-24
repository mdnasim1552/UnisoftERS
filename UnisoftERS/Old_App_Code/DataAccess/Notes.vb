Imports Microsoft.VisualBasic
Imports Constants
Imports System.Data.SqlClient
Imports System.Web


Public Class Notes

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    Public Function GetAdditionalNotesData(ByVal siteId As Integer) As DataTable
        Dim dsResult As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("additional_notes_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)> _
    Public Function SaveAdditionalNotesData(ByVal siteId As Integer, _
                                         ByVal additionalNotes As String) As Integer

        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("additional_notes_save", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
            cmd.Parameters.Add(New SqlParameter("@AdditionalNotes", HttpUtility.HtmlEncode(additionalNotes)))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

            cmd.Connection.Open()
            rowsAffected = cmd.ExecuteNonQuery()
        End Using

        Return rowsAffected
    End Function
End Class
