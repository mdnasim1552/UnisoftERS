Public Class SchedulerTransformation1
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

    End Sub

    Protected Sub btnTransformAll_Click(sender As Object, e As EventArgs)
        Try
            lblCompleteStatus.Text = "Transformation started " & Now

            Dim st As New SchedulerTransformation
            st.transformAllDiaries()
            lblCompleteStatus.Text += "Transformation complete " & Now
        Catch ex As Exception
            lblCompleteStatus.Text += "Transformation failed! " & Now & " " & ex.Message
        End Try
    End Sub

    Protected Sub btnTransformDiary_Click(sender As Object, e As EventArgs)
        If Not String.IsNullOrWhiteSpace(txtDiaryId.Text) Then
            Dim diaryId As Integer
            If Integer.TryParse(txtDiaryId.Text, diaryId) Then
                Try
                    lblCompleteStatus.Text = "Transformation started " & Now

                    Dim st As New SchedulerTransformation
                    st.transformDiary(diaryId)
                    lblCompleteStatus.Text += "Transformation complete " & Now
                Catch ex As CustomEx
                    lblCompleteStatus.Text += "Transformation failed for Diary ID " & ex.ErrorObjectId & "<br />" & ex.Message
                End Try

            End If
        End If

    End Sub
End Class