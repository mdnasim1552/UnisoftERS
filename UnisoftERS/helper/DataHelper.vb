Imports System.Data
Public Class DataHelper
    Public Shared Function GetColumnWiseSortedTable(ByVal dt As DataTable) As DataTable
        Dim resultDt As New DataTable()
        If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
            resultDt = dt.Clone()
            Dim midPoint As Integer = Math.Floor((dt.Rows.Count - 1) / 2)
            For i As Integer = 0 To midPoint
                resultDt.ImportRow(dt.Rows(i))
                Dim secondHalf As Integer = midPoint + i + 1
                If secondHalf < dt.Rows.Count Then
                    resultDt.ImportRow(dt.Rows(secondHalf))
                End If
            Next
        End If

        Return resultDt
    End Function

    Public Shared ReadOnly ProcedureNames As New Dictionary(Of Integer, String) From {
        {ProcedureType.Gastroscopy, "Gastroscopy"},
        {ProcedureType.ERCP, "ERCP"},
        {ProcedureType.Colonoscopy, "Colonoscopy"},
        {ProcedureType.Sigmoidscopy, "Sigmoidoscopy"},
        {ProcedureType.Proctoscopy, "Proctoscopy"},
        {ProcedureType.Bronchoscopy, "Bronchoscopy"},
        {ProcedureType.EBUS, "EBUS"},
        {ProcedureType.Antegrade, "Ent - Antegrade"},
        {ProcedureType.Retrograde, "Ent - Retrograde"},
        {ProcedureType.EUS_OGD, "EUS (OGD)"},
        {ProcedureType.EUS_HPB, "EUS (HPB)"},
        {ProcedureType.Flexi, "Cystoscopy"},
        {ProcedureType.Transnasal, "Transnasal"}
    }

    Public Shared Function GetProcedureName(ByVal procedureString As String, ByVal procType As Integer) As String
        Dim procName As String = String.Empty
        If ProcedureNames.TryGetValue(procType, procName) Then
            Return procName & " " & procedureString
        Else
            Return procedureString
        End If
    End Function
End Class
