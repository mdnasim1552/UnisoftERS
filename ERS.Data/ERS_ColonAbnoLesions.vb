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

Partial Public Class ERS_ColonAbnoLesions
    Public Property AbnoLesionId As Integer
    Public Property SiteId As Integer
    Public Property None As Boolean
    Public Property Sessile As Boolean
    Public Property SessileQuantity As Nullable(Of Integer)
    Public Property SessileLargest As Nullable(Of Integer)
    Public Property SessileExcised As Nullable(Of Integer)
    Public Property SessileRetrieved As Nullable(Of Integer)
    Public Property SessileToLabs As Nullable(Of Integer)
    Public Property SessileRemoval As Byte
    Public Property SessileRemovalMethod As Byte
    Public Property SessileProbably As Boolean
    Public Property SessileType As Byte
    Public Property SessileParisClass As Byte
    Public Property SessilePitPattern As Byte
    Public Property Pedunculated As Boolean
    Public Property PedunculatedQuantity As Nullable(Of Integer)
    Public Property PedunculatedLargest As Nullable(Of Integer)
    Public Property PedunculatedExcised As Nullable(Of Integer)
    Public Property PedunculatedRetrieved As Nullable(Of Integer)
    Public Property PedunculatedToLabs As Nullable(Of Integer)
    Public Property PedunculatedRemoval As Byte
    Public Property PedunculatedRemovalMethod As Byte
    Public Property PedunculatedProbably As Boolean
    Public Property PedunculatedType As Byte
    Public Property PedunculatedParisClass As Byte
    Public Property PedunculatedPitPattern As Byte
    Public Property Pseudopolyps As Boolean
    Public Property PseudopolypsMultiple As Boolean
    Public Property PseudopolypsQuantity As Nullable(Of Integer)
    Public Property PseudopolypsLargest As Nullable(Of Integer)
    Public Property PseudopolypsExcised As Nullable(Of Integer)
    Public Property PseudopolypsRetrieved As Nullable(Of Integer)
    Public Property PseudopolypsToLabs As Nullable(Of Integer)
    Public Property PseudopolypsInflam As Boolean
    Public Property PseudopolypsPostInflam As Boolean
    Public Property PseudopolypsRemoval As Byte
    Public Property PseudopolypsRemovalMethod As Byte
    Public Property Submucosal As Boolean
    Public Property SubmucosalQuantity As Nullable(Of Integer)
    Public Property SubmucosalLargest As Nullable(Of Integer)
    Public Property SubmucosalProbably As Boolean
    Public Property SubmucosalType As Byte
    Public Property Villous As Boolean
    Public Property VillousQuantity As Nullable(Of Integer)
    Public Property VillousLargest As Nullable(Of Integer)
    Public Property VillousProbably As Boolean
    Public Property VillousType As Byte
    Public Property Ulcerative As Boolean
    Public Property UlcerativeQuantity As Nullable(Of Integer)
    Public Property UlcerativeLargest As Nullable(Of Integer)
    Public Property UlcerativeProbably As Boolean
    Public Property UlcerativeType As Byte
    Public Property Stricturing As Boolean
    Public Property StricturingQuantity As Nullable(Of Integer)
    Public Property StricturingLargest As Nullable(Of Integer)
    Public Property StricturingProbably As Boolean
    Public Property StricturingType As Byte
    Public Property Polypoidal As Boolean
    Public Property PolypoidalQuantity As Nullable(Of Integer)
    Public Property PolypoidalLargest As Nullable(Of Integer)
    Public Property PolypoidalProbably As Boolean
    Public Property PolypoidalType As Byte
    Public Property Granuloma As Boolean
    Public Property GranulomaQuantity As Nullable(Of Integer)
    Public Property GranulomaLargest As Nullable(Of Integer)
    Public Property Dysplastic As Boolean
    Public Property DysplasticQuantity As Nullable(Of Integer)
    Public Property DysplasticLargest As Nullable(Of Integer)
    Public Property PneumatosisColi As Boolean
    Public Property Tattooed As Nullable(Of Boolean)
    Public Property PreviouslyTattooed As Nullable(Of Boolean)
    Public Property TattooType As Nullable(Of Integer)
    Public Property TattooedQuantity As Nullable(Of Integer)
    Public Property TattooedBy As Nullable(Of Integer)
    Public Property Summary As String
    Public Property WhoUpdatedId As Nullable(Of Integer)
    Public Property WhoCreatedId As Nullable(Of Integer)
    Public Property WhenCreated As Nullable(Of Date)
    Public Property WhenUpdated As Nullable(Of Date)
    Public Property SessileSuccessful As Nullable(Of Integer)
    Public Property PedunculatedSuccessful As Nullable(Of Integer)
    Public Property PseudopolypsSuccessful As Nullable(Of Integer)
    Public Property TattooLocationTop As Nullable(Of Boolean)
    Public Property TattooLocationLeft As Nullable(Of Boolean)
    Public Property TattooLocationRight As Nullable(Of Boolean)
    Public Property TattooLocationBottom As Nullable(Of Boolean)
    Public Property FundicGlandPolyp As Boolean
    Public Property FundicGlandPolypQuantity As Integer
    Public Property FundicGlandPolypLargest As Decimal

    Public Overridable Property ERS_Sites As ERS_Sites

End Class
