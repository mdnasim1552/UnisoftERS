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

Partial Public Class ERS_Sites
    Public Property SiteId As Integer
    Public Property ProcedureId As Nullable(Of Integer)
    Public Property SiteNo As Integer
    Public Property AreaNo As Integer
    Public Property RegionId As Integer
    Public Property XCoordinate As Integer
    Public Property YCoordinate As Integer
    Public Property AntPos As Nullable(Of Byte)
    Public Property PositionSpecified As Nullable(Of Boolean)
    Public Property DiagramHeight As Integer
    Public Property DiagramWidth As Integer
    Public Property SiteSummary As String
    Public Property SiteSummarySpecimens As String
    Public Property SiteSummaryTherapeutics As String
    Public Property SiteSummaryWithLinks As String
    Public Property SiteSummarySpecimensWithLinks As String
    Public Property SiteSummaryTherapeuticsWithLinks As String
    Public Property AdditionalNotes As String
    Public Property WhoUpdatedId As Nullable(Of Integer)
    Public Property WhoCreatedId As Nullable(Of Integer)
    Public Property WhenCreated As Nullable(Of Date)
    Public Property WhenUpdated As Nullable(Of Date)
    Public Property HasAbnormalities As Nullable(Of Integer)
    Public Property IsLymphNode As Nullable(Of Boolean)
    Public Property IsProtocol As Boolean
    Public Property EBUSLymphNodeSiteId As Nullable(Of Integer)
    Public Property EBUSLymphNodeSiteSuppressed As Boolean

    Public Overridable Property ERS_ColonAbnoLesions As ICollection(Of ERS_ColonAbnoLesions) = New HashSet(Of ERS_ColonAbnoLesions)
    Public Overridable Property ERS_ColonAbnoTumour As ICollection(Of ERS_ColonAbnoTumour) = New HashSet(Of ERS_ColonAbnoTumour)
    Public Overridable Property ERS_CommonAbnoLesions As ICollection(Of ERS_CommonAbnoLesions) = New HashSet(Of ERS_CommonAbnoLesions)
    Public Overridable Property ERS_CommonAbnoTumour As ICollection(Of ERS_CommonAbnoTumour) = New HashSet(Of ERS_CommonAbnoTumour)
    Public Overridable Property ERS_Photos As ICollection(Of ERS_Photos) = New HashSet(Of ERS_Photos)
    Public Overridable Property ERS_RecordCount As ICollection(Of ERS_RecordCount) = New HashSet(Of ERS_RecordCount)
    Public Overridable Property ERS_UpperGISpecimens As ICollection(Of ERS_UpperGISpecimens) = New HashSet(Of ERS_UpperGISpecimens)
    Public Overridable Property ERS_ERCPTherapeutics As ICollection(Of ERS_ERCPTherapeutics) = New HashSet(Of ERS_ERCPTherapeutics)
    Public Overridable Property ERS_Procedures As ERS_Procedures
    Public Overridable Property ERS_UpperGITherapeutics As ICollection(Of ERS_UpperGITherapeutics) = New HashSet(Of ERS_UpperGITherapeutics)

End Class
