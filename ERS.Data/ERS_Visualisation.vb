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

Partial Public Class ERS_Visualisation
    Public Property ID As Integer
    Public Property ProcedureID As Integer
    Public Property AccessVia As Nullable(Of Short)
    Public Property AccessViaOtherText As String
    Public Property MajorPapillaBile As Nullable(Of Short)
    Public Property MajorPapillaBileReason As String
    Public Property MajorPapillaPancreatic As Nullable(Of Short)
    Public Property MajorPapillaPancreaticReason As String
    Public Property MinorPapilla As Nullable(Of Short)
    Public Property MinorPapillaReason As String
    Public Property Abandoned As Nullable(Of Boolean)
    Public Property IntendedBileDuct As Nullable(Of Boolean)
    Public Property IntendedPancreaticDuct As Nullable(Of Boolean)
    Public Property MajorPapillaBile_ER As Nullable(Of Short)
    Public Property MajorPapillaBileReason_ER As String
    Public Property MajorPapillaPancreatic_ER As Nullable(Of Short)
    Public Property MajorPapillaPancreaticReason_ER As String
    Public Property MinorPapilla_ER As Nullable(Of Short)
    Public Property MinorPapillaReason_ER As String
    Public Property Abandoned_ER As Nullable(Of Boolean)
    Public Property IntendedBileDuct_ER As Nullable(Of Boolean)
    Public Property IntendedPancreaticDuct_ER As Nullable(Of Boolean)
    Public Property HepatobiliaryNotVisualised As Nullable(Of Boolean)
    Public Property HepatobiliaryWholeBiliary As Nullable(Of Boolean)
    Public Property ExceptBileDuct As Nullable(Of Boolean)
    Public Property ExceptGallBladder As Nullable(Of Boolean)
    Public Property ExceptCommonHepaticDuct As Nullable(Of Boolean)
    Public Property ExceptRightHepaticDuct As Nullable(Of Boolean)
    Public Property ExceptLeftHepaticDuct As Nullable(Of Boolean)
    Public Property HepatobiliaryAcinarFilling As Nullable(Of Boolean)
    Public Property HepatobiliaryLimitedBy As Nullable(Of Short)
    Public Property HepatobiliaryLimitedByOtherText As String
    Public Property PancreaticNotVisualised As Nullable(Of Boolean)
    Public Property PancreaticDivisum As Nullable(Of Boolean)
    Public Property PancreaticWhole As Nullable(Of Boolean)
    Public Property ExceptAccesoryPancreatic As Nullable(Of Boolean)
    Public Property ExceptMainPancreatic As Nullable(Of Boolean)
    Public Property ExceptUncinate As Nullable(Of Boolean)
    Public Property ExceptHead As Nullable(Of Boolean)
    Public Property ExceptNeck As Nullable(Of Boolean)
    Public Property ExceptBody As Nullable(Of Boolean)
    Public Property ExceptTail As Nullable(Of Boolean)
    Public Property PancreaticAcinar As Nullable(Of Boolean)
    Public Property PancreaticLimitedBy As Nullable(Of Short)
    Public Property PancreaticLimitedByOtherText As String
    Public Property HepatobiliaryFirst As Nullable(Of Short)
    Public Property HepatobiliaryFirstML As String
    Public Property HepatobiliarySecond As Nullable(Of Short)
    Public Property HepatobiliarySecondML As String
    Public Property HepatobiliaryBalloon As Nullable(Of Boolean)
    Public Property PancreaticFirst As Nullable(Of Short)
    Public Property PancreaticFirstML As String
    Public Property PancreaticSecond As Nullable(Of Short)
    Public Property PancreaticSecondML As String
    Public Property PancreaticBalloon As Nullable(Of Boolean)
    Public Property Summary As String
    Public Property WhoUpdatedId As Nullable(Of Integer)
    Public Property WhoCreatedId As Nullable(Of Integer)
    Public Property WhenCreated As Nullable(Of Date)
    Public Property WhenUpdated As Nullable(Of Date)
    Public Property DuodenumNormal As Boolean
    Public Property DuodenumNotEntered As Boolean
    Public Property Duodenum2ndPartNotEntered As Boolean
    Public Property AmpullaNotVisualised As Boolean
    Public Property SphincterotomyAttempts As Nullable(Of Short)
    Public Property SphincterotomyAttemptsOtherText As String

    Public Overridable Property ERS_Procedures As ERS_Procedures

End Class
