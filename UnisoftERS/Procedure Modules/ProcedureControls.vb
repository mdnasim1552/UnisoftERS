Public Class ProcedureControls
    Inherits System.Web.UI.UserControl


    Private _dataAdapter As DataAccess = Nothing

    Protected ReadOnly Property DataAdapter() As DataAccess
        Get
            If _dataAdapter Is Nothing Then
                _dataAdapter = New DataAccess
            End If
            Return _dataAdapter
        End Get
    End Property

    ''' <summary>
    ''' For use of control which prefix 'None' as their selected index.
    ''' This ensures that the control gets set as marked as complete for required fields check
    ''' </summary>
    ''' <param name="sectionName">name of section as in dbo.UI_Sections</param>
    ''' <param name="procedureId">Current procedure id</param>
    Public Sub markSectionSelected(sectionName As String, procedureId As Integer)
        DataAdapter.MarkSectionComplete(procedureId, sectionName)
    End Sub

End Class