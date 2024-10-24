

Imports System.Runtime.CompilerServices
Imports System.Security.Claims

Module ClaimExtension
    <Extension()>
    Function getName(ByVal claimIdentity As ClaimsIdentity) As String
        For Each claim In claimIdentity.Claims

            If claim.Type = ClaimTypes.Name Then
                Return claim.Value
            End If
        Next

        Return Nothing
    End Function
End Module
