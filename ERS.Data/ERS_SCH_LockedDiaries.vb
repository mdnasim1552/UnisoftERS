'------------------------------------------------------------------------------
' <auto-generated>
'     This code was generated from a template.
'
'     Manual changes to this file may cause unexpected behavior in your application.
'     Manual changes to this file will be overwritten if the code is regenerated.
' </auto-generated>
'------------------------------------------------------------------------------

Imports System
Imports System.Collections.Generic

Partial Public Class ERS_SCH_LockedDiaries
    Public Property LockedDiaryId As Integer
    Public Property DiaryId As Integer
    Public Property DiaryDate As Nullable(Of Date)
    Public Property Locked As Nullable(Of Boolean)
    Public Property LockedReasonId As Nullable(Of Integer)
    Public Property UnlockedReasonId As Nullable(Of Integer)
    Public Property LockAuthorizatonText As String
    Public Property UnlockAuthorizatonText As String
    Public Property LockedDateTime As Date
    Public Property UnlockedDateTime As Nullable(Of Date)
    Public Property WhoCreatedId As Nullable(Of Integer)
    Public Property WhenCreated As Nullable(Of Date)
    Public Property WhoUpdatedId As Nullable(Of Integer)
    Public Property WhenUpdated As Nullable(Of Date)
    Public Property AM As Boolean
    Public Property PM As Boolean
    Public Property EVE As Nullable(Of Boolean)

End Class
