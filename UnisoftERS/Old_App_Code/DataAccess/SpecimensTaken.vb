Imports Microsoft.VisualBasic
Imports Constants
Imports System.Data.SqlClient

Public Class SpecimensTaken

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetOgdSpecimensData(ByVal siteId As Integer) As DataTable
        Using da As New DataAccess
            Return da.ExecuteSP("specimens_ogd_select", New SqlParameter() {New SqlParameter("@SiteId", siteId)})
        End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetUreaseResult(ByVal procedureID As Integer) As DataTable
        Dim sSQL As New StringBuilder
        sSQL.Append("SELECT TOP 1 eug.Urease, eug.UreaseResult ")
        sSQL.Append("FROM dbo.ERS_UpperGISpecimens eug ")
        sSQL.Append("INNER JOIN dbo.ERS_Sites es ON eug.SiteId = es.SiteId ")
        sSQL.Append("INNER JOIN dbo.ERS_Procedures ep ON es.ProcedureId = ep.ProcedureId ")
        sSQL.Append("WHERE Urease = 1 AND ep.ProcedureID = @ProcedureID")

        Using da As New DataAccess
            Return DataAccess.ExecuteSQL(sSQL.ToString(), New SqlParameter() {New SqlParameter("@ProcedureID", procedureID)})
        End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function UpdateUreaseResult(ByVal procedureID As Integer, ByVal ureaseResult As Integer)
        Dim sSQL As New StringBuilder
        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            sSQL.Append("UPDATE eug ")
            sSQL.Append("SET eug.UreaseResult = @UreaseResult ")
            sSQL.Append("FROM ERS_UpperGISpecimens eug ")
            sSQL.Append("INNER JOIN dbo.ERS_Sites es ON eug.SiteId = es.SiteId ")
            sSQL.Append("INNER JOIN dbo.ERS_Procedures ep ON es.ProcedureId = ep.ProcedureId ")
            sSQL.Append("WHERE Urease = 1 AND ep.ProcedureID = @ProcedureID")

            Dim cmd As New SqlCommand(sSQL.ToString(), connection)
            cmd.CommandType = CommandType.Text

            cmd.Parameters.Add(New SqlParameter("@UreaseResult", ureaseResult))
            cmd.Parameters.Add(New SqlParameter("@ProcedureID", procedureID))

            cmd.Connection.Open()
            rowsAffected = cmd.ExecuteNonQuery()
        End Using

        Return rowsAffected
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveOgdSpecimensData(ByVal siteId As Integer,
                                         ByVal none As Boolean,
                                         ByVal brushCytology As Boolean,
                                         ByVal biopsy As Boolean,
                                         ByVal biopsiesTakenAtRandom As Boolean,
                                         ByVal biopsiesTakenAtSites As Boolean,
                                         ByVal biopsyQtyHistology As Double,
                                         ByVal biopsyQtyMicrobiology As Double,
                                         ByVal biopsyQtyVirology As Double,
                                         ByVal BiopsyDistance As Double,
                                         ByVal forcepType As Integer,
                                         ByVal forcepSerialNo As String,
                                         ByVal urease As Boolean,
                                         ByVal ureaseResult As Integer,
                                         ByVal polypectomy As Boolean,
                                         ByVal polypectomyQty As Double,
                                         ByVal hotBiopsy As Boolean,
                                         ByVal needleAspirate As Boolean,
                                         ByVal needleAspirateHistology As Boolean,
                                         ByVal needleAspirateMicrobiology As Boolean,
                                         ByVal needleAspirateVirology As Boolean,
                                         ByVal gastricWashing As Boolean,
                                         ByVal bile_PanJuice As Boolean,
                                         ByVal bile_PanJuiceCytology As Boolean,
                                         ByVal bile_PanJuiceBacteriology As Boolean,
                                         ByVal bile_PanJuiceAnalysis As Boolean,
                                         ByVal EUSFNANumberOfPasses As Integer,
                                         ByVal EUSFNANeedleGauge As Integer,
                                         ByVal FNB As Boolean,
                                         ByVal EUSFNBNumberOfPasses As Integer,
                                         ByVal EUSFNBNeedleGauge As Integer,
                                         ByVal BrushBiopsy As Boolean,
                                         ByVal TumourMarkers As Boolean,
                                         ByVal AmylaseLipase As Boolean,
                                         ByVal CytologyHistology As Boolean,
                                         ByVal FNASampleAssessedAtProcedure As Boolean,
                                         ByVal AdequateFNA As Boolean,
                                         ByVal FNBSampleAssessedAtProcedure As Boolean,
                                         ByVal AdequateFNB As Boolean,
                                         ByVal needleBiopsyHistology As Boolean,
                                         ByVal needleBiopsyCytology As Boolean,
                                         ByVal needleBiopsyMicrobiology As Boolean,
                                         ByVal needleBiopsyVirology As Boolean) As Integer

        Dim rowsAffected As Integer

        'MH Added on 24 Aug 2021
        If Not FNASampleAssessedAtProcedure Then
            AdequateFNA = False
        End If

        If Not FNBSampleAssessedAtProcedure Then
            AdequateFNB = False
        End If

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("specimens_ogd_save", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
            cmd.Parameters.Add(New SqlParameter("@None", none))
            cmd.Parameters.Add(New SqlParameter("@BrushCytology", brushCytology))
            cmd.Parameters.Add(New SqlParameter("@Biopsy", biopsy))
            cmd.Parameters.Add(New SqlParameter("@BiopsiesTakenAtRandom", biopsiesTakenAtRandom))
            cmd.Parameters.Add(New SqlParameter("@BiopsiesTakenAtSites", biopsiesTakenAtSites))
            cmd.Parameters.Add(New SqlParameter("@BiopsyQtyHistology", biopsyQtyHistology))
            cmd.Parameters.Add(New SqlParameter("@BiopsyQtyMicrobiology", biopsyQtyMicrobiology))
            cmd.Parameters.Add(New SqlParameter("@BiopsyQtyVirology", biopsyQtyVirology))
            cmd.Parameters.Add(New SqlParameter("@BiopsyDistance", BiopsyDistance))
            'If forcepType.HasValue Then
            cmd.Parameters.Add(New SqlParameter("@ForcepType", forcepType))
            'Else
            '    cmd.Parameters.Add(New SqlParameter("@ForcepType", SqlTypes.SqlInt32.Null))
            'End If
            'If forcepSerialNo.HasValue Then
            cmd.Parameters.Add(New SqlParameter("@ForcepSerialNo", IIf(forcepSerialNo Is Nothing, "", forcepSerialNo)))
            'Else
            '    cmd.Parameters.Add(New SqlParameter("@ForcepSerialNo", SqlTypes.SqlInt32.Null))
            'End If
            cmd.Parameters.Add(New SqlParameter("@Urease", urease))
            cmd.Parameters.Add(New SqlParameter("@UreaseResult", ureaseResult))
            cmd.Parameters.Add(New SqlParameter("@Polypectomy", polypectomy))
            cmd.Parameters.Add(New SqlParameter("@PolypectomyQty", polypectomyQty))
            cmd.Parameters.Add(New SqlParameter("@HotBiopsy", hotBiopsy))
            cmd.Parameters.Add(New SqlParameter("@NeedleAspirate", needleAspirate))
            cmd.Parameters.Add(New SqlParameter("@NeedleAspirateHistology", needleAspirateHistology))
            cmd.Parameters.Add(New SqlParameter("@NeedleAspirateMicrobiology", needleAspirateMicrobiology))
            cmd.Parameters.Add(New SqlParameter("@NeedleAspirateVirology", needleAspirateVirology))
            cmd.Parameters.Add(New SqlParameter("@GastricWashing", gastricWashing))

            cmd.Parameters.Add(New SqlParameter("@bile_PanJuice", bile_PanJuice))
            cmd.Parameters.Add(New SqlParameter("@bile_PanJuiceCytology", bile_PanJuiceCytology))
            cmd.Parameters.Add(New SqlParameter("@bile_PanJuiceBacteriology", bile_PanJuiceBacteriology))
            cmd.Parameters.Add(New SqlParameter("@bile_PanJuiceAnalysis", bile_PanJuiceAnalysis))

            cmd.Parameters.Add(New SqlParameter("@EUSFNANumberOfPasses", EUSFNANumberOfPasses))
            cmd.Parameters.Add(New SqlParameter("@EUSFNANeedleGauge", EUSFNANeedleGauge))

            cmd.Parameters.Add(New SqlParameter("@FNB", FNB))
            cmd.Parameters.Add(New SqlParameter("@EUSFNBNumberOfPasses", EUSFNBNumberOfPasses))
            cmd.Parameters.Add(New SqlParameter("@EUSFNBNeedleGauge", EUSFNBNeedleGauge))
            cmd.Parameters.Add(New SqlParameter("@BrushBiopsy", BrushBiopsy))
            cmd.Parameters.Add(New SqlParameter("@TumourMarkers", TumourMarkers))
            cmd.Parameters.Add(New SqlParameter("@AmylaseLipase", AmylaseLipase))
            cmd.Parameters.Add(New SqlParameter("@CytologyHistology", CytologyHistology))
            cmd.Parameters.Add(New SqlParameter("@FNASampleAssessedAtProcedure", FNASampleAssessedAtProcedure))
            cmd.Parameters.Add(New SqlParameter("@AdequateFNA", AdequateFNA))
            cmd.Parameters.Add(New SqlParameter("@FNBSampleAssessedAtProcedure", FNBSampleAssessedAtProcedure))
            cmd.Parameters.Add(New SqlParameter("@AdequateFNB", AdequateFNB))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))
            cmd.Parameters.Add(New SqlParameter("@NeedleBiopsyHistology", needleBiopsyHistology))
            cmd.Parameters.Add(New SqlParameter("@NeedleBiopsyCytology", needleBiopsyCytology))
            cmd.Parameters.Add(New SqlParameter("@NeedleBiopsyMicrobiology", needleBiopsyMicrobiology))
            cmd.Parameters.Add(New SqlParameter("@NeedleBiopsyVirology", needleBiopsyVirology))


            cmd.Connection.Open()
            rowsAffected = cmd.ExecuteNonQuery()
        End Using
        Return rowsAffected

    End Function

    Public Function GetBronchoSpecimensData(ByVal siteId As Integer) As DataTable
        Using da As New DataAccess
            Return da.ExecuteSP("specimens_brt_select", New SqlParameter() {New SqlParameter("@SiteId", siteId)})
        End Using
    End Function

    Public Function SaveBRTSpecimensData(ByVal siteId As Integer,
                                        ByVal None As Nullable(Of Boolean),
                                        ByVal EBUSTB As Nullable(Of Integer),
                                        ByVal EBUSHistology As Nullable(Of Integer),
                                        ByVal EBUSCytology As Nullable(Of Integer),
                                        ByVal EBUSBacteriology As Nullable(Of Integer),
                                        ByVal EndobronchialTB As Nullable(Of Integer),
                                        ByVal EndobronchialHistology As Nullable(Of Integer),
                                        ByVal EndobronchialBacteriology As Nullable(Of Integer),
                                        ByVal EndobronchialVirology As Nullable(Of Integer),
                                        ByVal EndobronchialMycology As Nullable(Of Integer),
                                        ByVal BrushCytology As Nullable(Of Integer),
                                        ByVal BrushBacteriology As Nullable(Of Integer),
                                        ByVal BrushVirology As Nullable(Of Integer),
                                        ByVal BrushMycology As Nullable(Of Integer),
                                        ByVal DistalBlindTB As Nullable(Of Integer),
                                        ByVal DistalBlindHistology As Nullable(Of Integer),
                                        ByVal DistalBlindBacteriology As Nullable(Of Integer),
                                        ByVal DistalBlindVirology As Nullable(Of Integer),
                                        ByVal DistalBlindMycology As Nullable(Of Integer),
                                        ByVal TransbronchialTB As Nullable(Of Integer),
                                        ByVal TransbronchialHistology As Nullable(Of Integer),
                                        ByVal TransbronchialBacteriology As Nullable(Of Integer),
                                        ByVal TransbronchialVirology As Nullable(Of Integer),
                                        ByVal TransbronchialMycology As Nullable(Of Integer),
                                        ByVal TranstrachealHistology As Nullable(Of Integer),
                                        ByVal TranstrachealBacteriology As Nullable(Of Integer),
                                        ByVal TranstrachealVirology As Nullable(Of Integer),
                                        ByVal TranstrachealMycology As Nullable(Of Integer),
                                        ByVal TrapPCP As Nullable(Of Integer),
                                        ByVal TrapTB As Nullable(Of Integer),
                                        ByVal TrapCytology As Nullable(Of Integer),
                                        ByVal TrapBacteriology As Nullable(Of Integer),
                                        ByVal TrapVirology As Nullable(Of Integer),
                                        ByVal TrapMycology As Nullable(Of Integer),
                                        ByVal BALPCP As Nullable(Of Integer),
                                        ByVal BALTB As Nullable(Of Integer),
                                        ByVal BALCytology As Nullable(Of Integer),
                                        ByVal BALBacteriology As Nullable(Of Integer),
                                        ByVal BALVirology As Nullable(Of Integer),
                                        ByVal BALMycology As Nullable(Of Integer),
                                        ByVal BALVolInfused As Nullable(Of Decimal),
                                        ByVal BALVolRecovered As Nullable(Of Decimal),
                                        ByVal FNATB As Nullable(Of Integer),
                                        ByVal FNACytology As Nullable(Of Integer),
                                        ByVal FNABacteriology As Nullable(Of Integer),
                                        ByVal FNAVirology As Nullable(Of Integer),
                                        ByVal FNAMycology As Nullable(Of Integer),
                                        ByVal FNAHistology As Nullable(Of Integer),
                                        ByVal CryoHistology As Nullable(Of Integer),
                                        ByVal FungalCultureMycology As Nullable(Of Integer)) As Integer

        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("specimens_brt_save", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@SiteID", siteId))
            cmd.Parameters.Add(New SqlParameter("@None", None))
            cmd.Parameters.Add(New SqlParameter("@EBUSTB", If(EBUSTB, 0)))
            cmd.Parameters.Add(New SqlParameter("@EBUSHistology", If(EBUSHistology, 0)))
            cmd.Parameters.Add(New SqlParameter("@EBUSCytology", If(EBUSCytology, 0)))
            cmd.Parameters.Add(New SqlParameter("@EBUSBacteriology", If(EBUSBacteriology, 0)))
            cmd.Parameters.Add(New SqlParameter("@EndobronchialTB", If(EndobronchialTB, 0)))
            cmd.Parameters.Add(New SqlParameter("@EndobronchialHistology", If(EndobronchialHistology, 0)))
            cmd.Parameters.Add(New SqlParameter("@EndobronchialBacteriology", If(EndobronchialBacteriology, 0)))
            cmd.Parameters.Add(New SqlParameter("@EndobronchialVirology", If(EndobronchialVirology, 0)))
            cmd.Parameters.Add(New SqlParameter("@EndobronchialMycology", If(EndobronchialMycology, 0)))
            cmd.Parameters.Add(New SqlParameter("@BrushCytology", If(BrushCytology, 0)))
            cmd.Parameters.Add(New SqlParameter("@BrushBacteriology", If(BrushBacteriology, 0)))
            cmd.Parameters.Add(New SqlParameter("@BrushVirology", If(BrushVirology, 0)))
            cmd.Parameters.Add(New SqlParameter("@BrushMycology", If(BrushMycology, 0)))
            cmd.Parameters.Add(New SqlParameter("@DistalBlindTB", If(DistalBlindTB, 0)))
            cmd.Parameters.Add(New SqlParameter("@DistalBlindHistology", If(DistalBlindHistology, 0)))
            cmd.Parameters.Add(New SqlParameter("@DistalBlindBacteriology", If(DistalBlindBacteriology, 0)))
            cmd.Parameters.Add(New SqlParameter("@DistalBlindVirology", If(DistalBlindVirology, 0)))
            cmd.Parameters.Add(New SqlParameter("@DistalBlindMycology", If(DistalBlindMycology, 0)))
            cmd.Parameters.Add(New SqlParameter("@TransbronchialTB", If(TransbronchialTB, 0)))
            cmd.Parameters.Add(New SqlParameter("@TransbronchialHistology", If(TransbronchialHistology, 0)))
            cmd.Parameters.Add(New SqlParameter("@TransbronchialBacteriology", If(TransbronchialBacteriology, 0)))
            cmd.Parameters.Add(New SqlParameter("@TransbronchialVirology", If(TransbronchialVirology, 0)))
            cmd.Parameters.Add(New SqlParameter("@TransbronchialMycology", If(TransbronchialMycology, 0)))
            cmd.Parameters.Add(New SqlParameter("@TranstrachealHistology", If(TranstrachealHistology, 0)))
            cmd.Parameters.Add(New SqlParameter("@TranstrachealBacteriology", If(TranstrachealBacteriology, 0)))
            cmd.Parameters.Add(New SqlParameter("@TranstrachealVirology", If(TranstrachealVirology, 0)))
            cmd.Parameters.Add(New SqlParameter("@TranstrachealMycology", If(TranstrachealMycology, 0)))
            cmd.Parameters.Add(New SqlParameter("@TrapPCP", If(TrapPCP, 0)))
            cmd.Parameters.Add(New SqlParameter("@TrapTB", If(TrapTB, 0)))
            cmd.Parameters.Add(New SqlParameter("@TrapCytology", If(TrapCytology, 0)))
            cmd.Parameters.Add(New SqlParameter("@TrapBacteriology", If(TrapBacteriology, 0)))
            cmd.Parameters.Add(New SqlParameter("@TrapVirology", If(TrapVirology, 0)))
            cmd.Parameters.Add(New SqlParameter("@TrapMycology", If(TrapMycology, 0)))
            cmd.Parameters.Add(New SqlParameter("@BALPCP", If(BALPCP, 0)))
            cmd.Parameters.Add(New SqlParameter("@BALTB", If(BALTB, 0)))
            cmd.Parameters.Add(New SqlParameter("@BALCytology", If(BALCytology, 0)))
            cmd.Parameters.Add(New SqlParameter("@BALBacteriology", If(BALBacteriology, 0)))
            cmd.Parameters.Add(New SqlParameter("@BALVirology", If(BALVirology, 0)))
            cmd.Parameters.Add(New SqlParameter("@BALMycology", If(BALMycology, 0)))
            If BALVolInfused.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@BALVolInfused", BALVolInfused))
            Else
                cmd.Parameters.Add(New SqlParameter("@BALVolInfused", SqlTypes.SqlDecimal.Null))
            End If
            If BALVolRecovered.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@BALVolRecovered", BALVolRecovered))
            Else
                cmd.Parameters.Add(New SqlParameter("@BALVolRecovered", SqlTypes.SqlDecimal.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@FNATB", If(FNATB, 0)))
            cmd.Parameters.Add(New SqlParameter("@FNACytology", If(FNACytology, 0)))
            cmd.Parameters.Add(New SqlParameter("@FNABacteriology", If(FNABacteriology, 0)))
            cmd.Parameters.Add(New SqlParameter("@FNAVirology", If(FNAVirology, 0)))
            cmd.Parameters.Add(New SqlParameter("@FNAMycology", If(FNAMycology, 0)))
            cmd.Parameters.Add(New SqlParameter("@FNAHistology", If(FNAHistology, 0)))
            cmd.Parameters.Add(New SqlParameter("@CryoHistology", If(CryoHistology, 0)))
            cmd.Parameters.Add(New SqlParameter("@FungalCultureMycology", If(FungalCultureMycology, 0)))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

            cmd.Connection.Open()
            rowsAffected = cmd.ExecuteNonQuery()
        End Using
        Return rowsAffected

    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetCystoScopySpecimensData(ByVal siteId As Integer) As DataTable
        Using da As New DataAccess
            Return da.ExecuteSP("specimens_cystoscopy_select", New SqlParameter() {New SqlParameter("@SiteId", siteId)})
        End Using
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveCystoscopySpecimensData(ByVal siteId As Integer,
                                        ByVal none As Boolean,
                                        ByVal qunatity As Double,
                                        ByVal qunatityCytology As Double,
                                        ByVal forcepsDisposable As Boolean,
                                        ByVal forcepsReusable As Boolean,
                                        ByVal forcepsReusableSerialNumber As String) As Integer

        Dim rowsAffected As Integer



        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("specimens_cystoscopy_save", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
            cmd.Parameters.Add(New SqlParameter("@None", none))
            cmd.Parameters.Add(New SqlParameter("@qunatity", qunatity))
            cmd.Parameters.Add(New SqlParameter("@qunatityCytology", qunatityCytology))
            cmd.Parameters.Add(New SqlParameter("@forcepsDisposable", forcepsDisposable))
            cmd.Parameters.Add(New SqlParameter("@forcepsReusable", forcepsReusable))
            cmd.Parameters.Add(New SqlParameter("@forcepsReusableSerialNumber", If(forcepsReusableSerialNumber, "")))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

            cmd.Connection.Open()
            rowsAffected = cmd.ExecuteNonQuery()
        End Using
        Return rowsAffected

    End Function
End Class
