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

Partial Public Class ERS_Photos
    Public Property PhotoId As Integer
    Public Property PhotoName As String
    Public Property PhotoBlob As Byte()
    Public Property ProcedureId As Integer
    Public Property SiteId As Nullable(Of Integer)
    Public Property IncludeInReport As Nullable(Of Boolean)
    Public Property DateTimeStamp As Nullable(Of Date)
    Public Property WhoUpdatedId As Nullable(Of Integer)
    Public Property WhoCreatedId As Nullable(Of Integer)
    Public Property WhenCreated As Nullable(Of Date)
    Public Property WhenUpdated As Nullable(Of Date)

    Public Overridable Property ERS_Sites As ERS_Sites
    Public Overridable Property ERS_Procedures As ERS_Procedures

End Class
