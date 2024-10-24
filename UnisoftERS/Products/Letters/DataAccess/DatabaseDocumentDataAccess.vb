Imports System.Data.SqlClient

Public Class DatabaseDocumentDataAccess
    Implements IDocumentDataAccess

    Public Function CheckLetterExistsForLetterQueue(LetterQueueId As Integer) As Boolean Implements IDocumentDataAccess.CheckLetterExistsForLetterQueue
        Try
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("letCheckIfLetterExists", connection) With {
                .CommandType = CommandType.StoredProcedure
            }
                cmd.Parameters.Add(New SqlParameter("@LetterQueueId", LetterQueueId))

                connection.Open()
                Dim r As Object = cmd.ExecuteScalar
                If Not IsDBNull(r) AndAlso Not IsNothing(r) Then
                    Return True
                Else
                    Return False
                End If
            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError($"Error occurred while checking if letter exists in database.  LetterQueueId : { LetterQueueId }", ex)
            Return False
        End Try
    End Function

    Public Function GetEditedLetterForLetterQueueId(LetterQueueId As Integer) As Byte() Implements IDocumentDataAccess.GetEditedLetterForLetterQueueId
        Try
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("letGetLetterContent", connection) With {
                    .CommandType = CommandType.StoredProcedure
                }
                cmd.Parameters.Add(New SqlParameter("@LetterQueueId", LetterQueueId))

                connection.Open()
                Dim r As Object = cmd.ExecuteScalar
                If Not IsDBNull(r) AndAlso Not IsNothing(r) Then
                    Return CType(r, Byte())
                Else
                    Return Nothing
                End If
            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError($"Error occurred while retrieving letter from database.  LetterQueueId : { LetterQueueId }", ex)
            Return Nothing
        End Try
    End Function

    Public Sub SaveEditedLetterQueue(LetterQueueId As Integer, EditedLetterContent() As Byte, Optional EditLetterReasonId As Integer? = 0, Optional EditLetterReasonExtraInfo As String = Nothing) Implements IDocumentDataAccess.SaveEditedLetterQueue
        Try
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("letSaveLetter", connection) With {
                        .CommandType = CommandType.StoredProcedure
                    }
                cmd.Parameters.Add(New SqlParameter("@LetterQueueId", LetterQueueId))
                cmd.Parameters.Add(New SqlParameter("@UserId", CInt(HttpContext.Current.Session("PKUserID"))))
                cmd.Parameters.Add(New SqlParameter("@LetterContent", EditedLetterContent))
                cmd.Parameters.Add(New SqlParameter("@EditLetterReasonId", EditLetterReasonId))
                cmd.Parameters.Add(New SqlParameter("@EditLetterReasonExtraInfo", If(EditLetterReasonExtraInfo, DBNull.Value)))
                connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError($"Error occurred while saving the letter to database.  LetterQueueId : { LetterQueueId }", ex)
        End Try
    End Sub
End Class
