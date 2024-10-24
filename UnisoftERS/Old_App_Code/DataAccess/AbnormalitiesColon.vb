Imports System.Data.SqlClient
Imports DevExpress.Web.ASPxHtmlEditor.Internal

Public Class AbnormalitiesColon

#Region "Miscellaneous"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetMiscellaneousData(ByVal siteId As Integer) As DataTable
        Dim da As New DataAccess
        Return da.GetAbnormalities(siteId, "ERS_ColonAbnoMiscellaneous")
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveMiscellaneousData(ByVal SiteId As Integer,
                                    ByVal None As Boolean,
                                    ByVal Crohn As Boolean,
                                    ByVal Fistula As Boolean,
                                    ByVal ForeignBody As Boolean,
                                    ByVal Lipoma As Boolean,
                                    ByVal Melanosis As Boolean,
                                    ByVal Parasites As Boolean,
                                    ByVal PneumatosisColi As Boolean,
                                    ByVal PolyposisSyndrome As Boolean,
                                    ByVal PostoperativeAppearance As Boolean,
                                    ByVal Pseudoobstruction As Boolean,
                                    ByVal Pouchitis As Boolean,
                                    ByVal Volvulus As Boolean,
                                    ByVal AmpullaryAdenoma As Boolean,
                                    ByVal StentInSitu As Boolean,
                                    ByVal PEGInSitu As Boolean,
                                    ByVal StentOcclusion As Boolean,
                                    ByVal Other As String) As Integer

        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("abnormalities_colon_miscellaneous_save", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
            cmd.Parameters.Add(New SqlParameter("@None", None))
            cmd.Parameters.Add(New SqlParameter("@Crohn", Crohn))
            cmd.Parameters.Add(New SqlParameter("@Fistula", Fistula))
            cmd.Parameters.Add(New SqlParameter("@ForeignBody", ForeignBody))
            cmd.Parameters.Add(New SqlParameter("@Lipoma", Lipoma))
            cmd.Parameters.Add(New SqlParameter("@Melanosis", Melanosis))
            cmd.Parameters.Add(New SqlParameter("@Parasites", Parasites))
            cmd.Parameters.Add(New SqlParameter("@PneumatosisColi", PneumatosisColi))
            cmd.Parameters.Add(New SqlParameter("@PolyposisSyndrome", PolyposisSyndrome))
            cmd.Parameters.Add(New SqlParameter("@PostoperativeAppearance", PostoperativeAppearance))
            cmd.Parameters.Add(New SqlParameter("@Pseudoobstruction", Pseudoobstruction))
            cmd.Parameters.Add(New SqlParameter("@Pouchitis", Pouchitis))
            cmd.Parameters.Add(New SqlParameter("@Volvulus", Volvulus))
            cmd.Parameters.Add(New SqlParameter("@AmpullaryAdenoma", AmpullaryAdenoma))
            cmd.Parameters.Add(New SqlParameter("@StentInSitu", StentInSitu))
            cmd.Parameters.Add(New SqlParameter("@PEGInSitu", PEGInSitu))
            cmd.Parameters.Add(New SqlParameter("@StentOcclusion", StentOcclusion))
            cmd.Parameters.Add(New SqlParameter("@Other", Other.Replace("<", "&lt;").Replace(">", "&gt;")))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

            connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function
#End Region

#Region "Calibre"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetCalibreData(ByVal siteId As Integer) As DataTable
        Dim da As New DataAccess
        Return da.GetAbnormalities(siteId, "ERS_ColonAbnoCalibre")
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveCalibreData(ByVal SiteId As Integer,
                                    ByVal None As Boolean,
                                    ByVal Contraction As Boolean,
                                    ByVal Dilated As Boolean,
                                    ByVal DilatedType As Integer,
                                    ByVal Obstruction As Boolean,
                                    ByVal Spasm As Boolean,
                                    ByVal Stricture As Boolean,
                                    ByVal StrictureType As Integer,
                                    ByVal Stricturelength As Nullable(Of Decimal),
                                    ByVal StrictureImpeded As Integer) As Integer

        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("abnormalities_calibre_save", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
            cmd.Parameters.Add(New SqlParameter("@None", None))
            cmd.Parameters.Add(New SqlParameter("@Contraction", Contraction))
            cmd.Parameters.Add(New SqlParameter("@Dilated", Dilated))
            cmd.Parameters.Add(New SqlParameter("@DilatedType", DilatedType))
            cmd.Parameters.Add(New SqlParameter("@Obstruction", Obstruction))
            cmd.Parameters.Add(New SqlParameter("@Spasm", Spasm))
            cmd.Parameters.Add(New SqlParameter("@Stricture", Stricture))
            cmd.Parameters.Add(New SqlParameter("@StrictureType", StrictureType))
            If Stricturelength.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@StrictureLength", Stricturelength))
            Else
                cmd.Parameters.Add(New SqlParameter("@StrictureLength", SqlTypes.SqlDecimal.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@StrictureImpeded", StrictureImpeded))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

            connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function
#End Region

#Region "Mucosa"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetMucosaData(ByVal siteId As Integer) As DataTable
        Dim da As New DataAccess
        Return da.GetAbnormalities(siteId, "ERS_ColonAbnoMucosa")
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveMucosaData(ByVal SiteId As Integer,
                                    ByVal None As Boolean,
                                    ByVal Atrophic As Boolean,
                                    ByVal AtrophicDistribution As Integer,
                                    ByVal AtrophicSeverity As Integer,
                                    ByVal Congested As Boolean,
                                    ByVal CongestedDistribution As Integer,
                                    ByVal CongestedSeverity As Integer,
                                    ByVal Erythematous As Boolean,
                                    ByVal ErythematousDistribution As Integer,
                                    ByVal ErythematousSeverity As Integer,
                                    ByVal Granular As Boolean,
                                    ByVal GranularDistribution As Integer,
                                    ByVal GranularSeverity As Integer,
                                    ByVal Exudate As Boolean,
                                    ByVal ExudateDistribution As Integer,
                                    ByVal ExudateSeverity As Integer,
                                    ByVal Pigmented As Boolean,
                                    ByVal PigmentedDistribution As Integer,
                                    ByVal PigmentedSeverity As Integer,
                                    ByVal RedundantRectal As Boolean,
                                    ByVal Ulcerative As Boolean,
                                    ByVal SmallUlcers As Boolean,
                                    ByVal SmallUlcersType As Integer,
                                    ByVal LargeUlcers As Boolean,
                                    ByVal LargeUlcersType As Integer,
                                    ByVal PleomorphicUlcers As Boolean,
                                    ByVal PleomorphicUlcersType As Integer,
                                    ByVal SerpiginousUlcers As Boolean,
                                    ByVal SerpiginousUlcersType As Integer,
                                    ByVal AphthousUlcers As Boolean,
                                    ByVal AphthousUlcersType As Integer,
                                    ByVal CobblestoneMucosa As Boolean,
                                    ByVal CobblestoneMucosaType As Integer,
                                    ByVal ConfluentUlceration As Boolean,
                                    ByVal DeepUlceration As Boolean,
                                    ByVal SolitaryUlcer As Boolean,
                                    ByVal SolitaryUlcerDiameter As Nullable(Of Integer),
                                    ByVal InflammatoryColitis As Boolean,
                                    ByVal InflammatoryIleitis As Boolean,
                                    ByVal InflammatoryProctitis As Boolean,
                                    ByVal InflammatoryDisorder As Integer,
                                    ByVal InflammatoryExtent As Integer,
                                    ByVal InflammatoryMayoScore As Integer,
                                    ByVal InflammatorySESCrohn As Integer,
                                    ByVal InflammatoryUCEISScoreing As Dictionary(Of String, Integer),
                                    ByVal CDEISScore As Integer,
                                    ByVal RutgeertsScore As Integer) As Integer

        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("abnormalities_mucosa_save", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
            cmd.Parameters.Add(New SqlParameter("@None", None))
            cmd.Parameters.Add(New SqlParameter("@Atrophic", Atrophic))
            cmd.Parameters.Add(New SqlParameter("@AtrophicDistribution", AtrophicDistribution))
            cmd.Parameters.Add(New SqlParameter("@AtrophicSeverity", AtrophicSeverity))
            cmd.Parameters.Add(New SqlParameter("@Congested", Congested))
            cmd.Parameters.Add(New SqlParameter("@CongestedDistribution", CongestedDistribution))
            cmd.Parameters.Add(New SqlParameter("@CongestedSeverity", CongestedSeverity))
            cmd.Parameters.Add(New SqlParameter("@Erythematous", Erythematous))
            cmd.Parameters.Add(New SqlParameter("@ErythematousDistribution", ErythematousDistribution))
            cmd.Parameters.Add(New SqlParameter("@ErythematousSeverity", ErythematousSeverity))
            cmd.Parameters.Add(New SqlParameter("@Granular", Granular))
            cmd.Parameters.Add(New SqlParameter("@GranularDistribution", GranularDistribution))
            cmd.Parameters.Add(New SqlParameter("@GranularSeverity", GranularSeverity))
            cmd.Parameters.Add(New SqlParameter("@Exudate", Exudate))
            cmd.Parameters.Add(New SqlParameter("@ExudateDistribution", ExudateDistribution))
            cmd.Parameters.Add(New SqlParameter("@ExudateSeverity", ExudateSeverity))
            cmd.Parameters.Add(New SqlParameter("@Pigmented", Pigmented))
            cmd.Parameters.Add(New SqlParameter("@PigmentedDistribution", PigmentedDistribution))
            cmd.Parameters.Add(New SqlParameter("@PigmentedSeverity", PigmentedSeverity))
            cmd.Parameters.Add(New SqlParameter("@RedundantRectal", RedundantRectal))
            cmd.Parameters.Add(New SqlParameter("@Ulcerative", Ulcerative))
            cmd.Parameters.Add(New SqlParameter("@SmallUlcers", SmallUlcers))
            cmd.Parameters.Add(New SqlParameter("@SmallUlcersType", SmallUlcersType))
            cmd.Parameters.Add(New SqlParameter("@LargeUlcers", LargeUlcers))
            cmd.Parameters.Add(New SqlParameter("@LargeUlcersType", LargeUlcersType))
            cmd.Parameters.Add(New SqlParameter("@PleomorphicUlcers", PleomorphicUlcers))
            cmd.Parameters.Add(New SqlParameter("@PleomorphicUlcersType", PleomorphicUlcersType))
            cmd.Parameters.Add(New SqlParameter("@SerpiginousUlcers", SerpiginousUlcers))
            cmd.Parameters.Add(New SqlParameter("@SerpiginousUlcersType", SerpiginousUlcersType))
            cmd.Parameters.Add(New SqlParameter("@AphthousUlcers", AphthousUlcers))
            cmd.Parameters.Add(New SqlParameter("@AphthousUlcersType", AphthousUlcersType))
            cmd.Parameters.Add(New SqlParameter("@CobblestoneMucosa", CobblestoneMucosa))
            cmd.Parameters.Add(New SqlParameter("@CobblestoneMucosaType", CobblestoneMucosaType))
            cmd.Parameters.Add(New SqlParameter("@ConfluentUlceration", ConfluentUlceration))
            cmd.Parameters.Add(New SqlParameter("@DeepUlceration", DeepUlceration))
            cmd.Parameters.Add(New SqlParameter("@SolitaryUlcer", SolitaryUlcer))
            If SolitaryUlcerDiameter.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@SolitaryUlcerDiameter", SolitaryUlcerDiameter))
            Else
                cmd.Parameters.Add(New SqlParameter("@SolitaryUlcerDiameter", SqlTypes.SqlInt32.Null))
            End If

            cmd.Parameters.Add(New SqlParameter("@InflammatoryColitis", InflammatoryColitis))
            cmd.Parameters.Add(New SqlParameter("@InflammatoryIleitis", InflammatoryIleitis))
            cmd.Parameters.Add(New SqlParameter("@InflammatoryProctitis", InflammatoryProctitis))
            cmd.Parameters.Add(New SqlParameter("@InflammatoryDisorder", InflammatoryDisorder))
            cmd.Parameters.Add(New SqlParameter("@InflammatoryExtent", InflammatoryExtent))
            cmd.Parameters.Add(New SqlParameter("@InflammatoryMayoScore", InflammatoryMayoScore))
            cmd.Parameters.Add(New SqlParameter("@InflammatorySESCrohn", InflammatorySESCrohn))
            cmd.Parameters.Add(New SqlParameter("@CDEISScore", CDEISScore))
            cmd.Parameters.Add(New SqlParameter("@RutgeertsScore", RutgeertsScore))

            If InflammatoryUCEISScoreing IsNot Nothing AndAlso InflammatoryUCEISScoreing.Count > 0 Then
                cmd.Parameters.Add(New SqlParameter("@VascularPatternUCEISScore", InflammatoryUCEISScoreing("vascular pattern")))
                cmd.Parameters.Add(New SqlParameter("@BleedingUCEISScore", InflammatoryUCEISScoreing("bleeding")))
                cmd.Parameters.Add(New SqlParameter("@ErosionsUCEISScore", InflammatoryUCEISScoreing("erosions and ulcers")))
            Else
                cmd.Parameters.Add(New SqlParameter("@VascularPatternUCEISScore", 0))
                cmd.Parameters.Add(New SqlParameter("@BleedingUCEISScore", 0))
                cmd.Parameters.Add(New SqlParameter("@ErosionsUCEISScore", 0))
            End If
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

            connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function
#End Region

#Region "Diverticulum"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetDiverticulumData(ByVal siteId As Integer) As DataTable
        Dim da As New DataAccess
        Return da.GetAbnormalities(siteId, "ERS_ColonAbnoDiverticulum")
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveDiverticulumData(ByVal SiteId As Integer,
                                        ByVal None As Boolean,
                                        ByVal MucosalInflammation As Boolean,
                                        ByVal Quantity As Integer,
                                        ByVal Distribution As Integer,
                                        ByVal NarrowingTortuosity As Boolean,
                                        ByVal Severity As Integer,
                                        ByVal CircMuscleHypertrophy As Boolean) As Integer

        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("abnormalities_colon_diverticulum_save", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
            cmd.Parameters.Add(New SqlParameter("@None", None))
            cmd.Parameters.Add(New SqlParameter("@MucosalInflammation", MucosalInflammation))
            cmd.Parameters.Add(New SqlParameter("@Quantity", Quantity))
            cmd.Parameters.Add(New SqlParameter("@Distribution", Distribution))
            cmd.Parameters.Add(New SqlParameter("@NarrowingTortuosity", NarrowingTortuosity))
            cmd.Parameters.Add(New SqlParameter("@Severity", Severity))
            cmd.Parameters.Add(New SqlParameter("@CircMuscleHypertrophy", CircMuscleHypertrophy))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

            connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function
#End Region

#Region "Lesions"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetLesionsData(ByVal siteId As Integer) As DataTable
        Dim da As New Abnormalities
        Return da.GetAbnormalities(siteId, "abnormalities_colon_lesions_select")
    End Function

    Public Function GetLesionsPolypData(ByVal siteId As Integer) As List(Of SitePolyps)
        Try
            Using db As New ERS.Data.GastroDbEntities
                Dim polypDetails = db.ERS_ColonAbnoPolypDetails.Where(Function(x) x.SiteId = siteId)
                If polypDetails.Count > 0 Then
                    Dim details As New List(Of SitePolyps)
                    For Each d In polypDetails
                        details.Add(New SitePolyps() With {
                            .Size = d.Size,
                            .Excised = d.Excised,
                            .Retrieved = d.Retreived,
                            .Successful = d.Successful,
                            .SentToLabs = d.Labs,
                            .Removal = d.Removal,
                            .RemovalMethod = d.RemovalMethod,
                            .Probably = d.Probably,
                            .TumourType = d.Type,
                            .Inflammatory = d.Infammatory,
                            .PostInflammatory = d.PostInflammatory,
                            .PitPattern = d.PitPattern,
                            .ParisClassification = d.ParisClass
                        })
                    Next

                    Return details
                Else
                    Return Nothing
                End If
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveLesions(ByVal SiteId As Integer,
                                    ByVal None As Boolean,
                                    ByVal Sessile As Boolean,
                                    ByVal SessileQuantity As Nullable(Of Integer),
                                    ByVal Pedunculated As Boolean,
                                    ByVal PedunculatedQuantity As Nullable(Of Integer),
                                    ByVal Pseudopolyps As Boolean,
                                    ByVal PseudopolypsQuantity As Nullable(Of Integer),
                                    ByVal PolypDetails As List(Of SitePolyps),
                                    ByVal Submucosal As Boolean,
                                    ByVal SubmucosalQuantity As Nullable(Of Integer),
                                    ByVal SubmucosalLargest As Nullable(Of Integer),
                                    ByVal SubmucosalProbably As Boolean,
                                    ByVal SubmucosalType As Integer,
                                    ByVal Villous As Boolean,
                                    ByVal VillousQuantity As Nullable(Of Integer),
                                    ByVal VillousLargest As Nullable(Of Integer),
                                    ByVal VillousProbably As Boolean,
                                    ByVal VillousType As Integer,
                                    ByVal Ulcerative As Boolean,
                                    ByVal UlcerativeQuantity As Nullable(Of Integer),
                                    ByVal UlcerativeLargest As Nullable(Of Integer),
                                    ByVal UlcerativeProbably As Boolean,
                                    ByVal UlcerativeType As Integer,
                                    ByVal Stricturing As Boolean,
                                    ByVal StricturingQuantity As Nullable(Of Integer),
                                    ByVal StricturingLargest As Nullable(Of Integer),
                                    ByVal StricturingProbably As Boolean,
                                    ByVal StricturingType As Integer,
                                    ByVal Polypoidal As Boolean,
                                    ByVal PolypoidalQuantity As Nullable(Of Integer),
                                    ByVal PolypoidalLargest As Nullable(Of Integer),
                                    ByVal PolypoidalProbably As Boolean,
                                    ByVal PolypoidalType As Integer,
                                    ByVal Granuloma As Boolean,
                                    ByVal GranulomaQuantity As Nullable(Of Integer),
                                    ByVal GranulomaLargest As Nullable(Of Integer),
                                    ByVal FundicGlandPolyp As Boolean,
                                    ByVal FundicGlandPolypQuantity As Nullable(Of Integer),
                                    ByVal FundicGlandPolypLargest As Nullable(Of Decimal),
                                    ByVal Dysplastic As Boolean,
                                    ByVal DysplasticQuantity As Nullable(Of Integer),
                                    ByVal DysplasticLargest As Nullable(Of Integer),
                                    ByVal PneumatosisColi As Boolean,
                                    ByVal Tattooed As Nullable(Of Boolean),
                                    ByVal PreviouslyTattooed As Nullable(Of Boolean),
                                    ByVal TattooType As Nullable(Of Integer),
                                    ByVal TattooedQuantity As Nullable(Of Integer),
                                    ByVal TattooLocationTop As Nullable(Of Boolean),
                                    ByVal TattooLocationLeft As Nullable(Of Boolean),
                                    ByVal TattooLocationRight As Nullable(Of Boolean),
                                    ByVal TattooLocationBottom As Nullable(Of Boolean),
                                    ByVal TattooedBy As Nullable(Of Integer)) As Integer

        Dim rowsAffected As Integer

        Try

            'update therapeutics
            Dim largestPolyp = 0
            Dim largestRemoval = 0
            Dim largestRemovalMethod = 0
            Dim largestProbably = False
            Dim largestInflam = False
            Dim largestPostInflam = False
            Dim largestType = 0
            Dim excisedQty = 0
            Dim retreivedQty = 0
            Dim sucessfullQty = 0
            Dim labsQty = 0

            If PolypDetails IsNot Nothing AndAlso PolypDetails.Count > 0 Then
                Dim largestPolypDetails = PolypDetails.OrderByDescending(Function(x) x.Size).FirstOrDefault
                largestPolyp = largestPolypDetails.Size
                largestRemoval = largestPolypDetails.Removal 'think.... what if the largest hasnt been removed?
                largestRemovalMethod = largestPolypDetails.RemovalMethod
                largestProbably = largestPolypDetails.Probably
                largestType = largestPolypDetails.TumourType
                largestInflam = largestPolypDetails.Inflammatory
                largestPostInflam = largestPolypDetails.PostInflammatory

                excisedQty = PolypDetails.Where(Function(x) x.Excised).Count
                retreivedQty = PolypDetails.Where(Function(x) x.Retrieved).Count
                sucessfullQty = PolypDetails.Where(Function(x) x.Successful).Count
                labsQty = PolypDetails.Where(Function(x) x.SentToLabs).Count
            End If

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As SqlCommand = New SqlCommand("abnormalities_colon_lesions_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
                cmd.Parameters.Add(New SqlParameter("@None", None))
                cmd.Parameters.Add(New SqlParameter("@Sessile", Sessile))

                If SessileQuantity.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@SessileQuantity", SessileQuantity))
                Else
                    cmd.Parameters.Add(New SqlParameter("@SessileQuantity", SqlTypes.SqlInt32.Null))
                End If

                If PolypDetails.Any(Function(x) x.PolypType.ToLower = "sessile") Then
                    cmd.Parameters.Add(New SqlParameter("@SessileLargest", largestPolyp))
                    cmd.Parameters.Add(New SqlParameter("@SessileExcised", excisedQty))
                    cmd.Parameters.Add(New SqlParameter("@SessileSuccessful", sucessfullQty))
                    cmd.Parameters.Add(New SqlParameter("@SessileRetrieved", retreivedQty))
                    cmd.Parameters.Add(New SqlParameter("@SessileToLabs", labsQty))
                    cmd.Parameters.Add(New SqlParameter("@SessileRemoval", largestRemoval))
                    cmd.Parameters.Add(New SqlParameter("@SessileRemovalMethod", largestRemovalMethod))
                    cmd.Parameters.Add(New SqlParameter("@SessileProbably", largestProbably))
                    cmd.Parameters.Add(New SqlParameter("@SessileType", largestType))
                Else
                    cmd.Parameters.Add(New SqlParameter("@SessileLargest", SqlTypes.SqlInt32.Null))
                    cmd.Parameters.Add(New SqlParameter("@SessileExcised", SqlTypes.SqlInt32.Null))
                    cmd.Parameters.Add(New SqlParameter("@SessileSuccessful", SqlTypes.SqlInt32.Null))
                    cmd.Parameters.Add(New SqlParameter("@SessileRetrieved", SqlTypes.SqlInt32.Null))
                    cmd.Parameters.Add(New SqlParameter("@SessileToLabs", SqlTypes.SqlInt32.Null))
                    cmd.Parameters.Add(New SqlParameter("@SessileRemoval", 0))
                    cmd.Parameters.Add(New SqlParameter("@SessileRemovalMethod", 0))
                    cmd.Parameters.Add(New SqlParameter("@SessileProbably", 0))
                    cmd.Parameters.Add(New SqlParameter("@SessileType", 0))
                End If
                cmd.Parameters.Add(New SqlParameter("@SessileParisClass", 0))
                cmd.Parameters.Add(New SqlParameter("@SessilePitPattern", 0))

                cmd.Parameters.Add(New SqlParameter("@Pedunculated", Pedunculated))
                If PedunculatedQuantity.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@PedunculatedQuantity", PedunculatedQuantity))
                Else
                    cmd.Parameters.Add(New SqlParameter("@PedunculatedQuantity", SqlTypes.SqlInt32.Null))
                End If

                If PolypDetails.Any(Function(x) x.PolypType.ToLower = "pedunculated") Then
                    cmd.Parameters.Add(New SqlParameter("@PedunculatedLargest", largestPolyp))
                    cmd.Parameters.Add(New SqlParameter("@PedunculatedExcised", excisedQty))
                    cmd.Parameters.Add(New SqlParameter("@PedunculatedSuccessful", sucessfullQty))
                    cmd.Parameters.Add(New SqlParameter("@PedunculatedRetrieved", retreivedQty))
                    cmd.Parameters.Add(New SqlParameter("@PedunculatedToLabs", labsQty))
                    cmd.Parameters.Add(New SqlParameter("@PedunculatedRemoval", largestRemoval))
                    cmd.Parameters.Add(New SqlParameter("@PedunculatedRemovalMethod", largestRemovalMethod))
                    cmd.Parameters.Add(New SqlParameter("@PedunculatedProbably", largestProbably))
                    cmd.Parameters.Add(New SqlParameter("@PedunculatedType", largestType))
                Else
                    cmd.Parameters.Add(New SqlParameter("@PedunculatedLargest", SqlTypes.SqlInt32.Null))
                    cmd.Parameters.Add(New SqlParameter("@PedunculatedExcised", SqlTypes.SqlInt32.Null))
                    cmd.Parameters.Add(New SqlParameter("@PedunculatedSuccessful", SqlTypes.SqlInt32.Null))
                    cmd.Parameters.Add(New SqlParameter("@PedunculatedRetrieved", SqlTypes.SqlInt32.Null))
                    cmd.Parameters.Add(New SqlParameter("@PedunculatedToLabs", SqlTypes.SqlInt32.Null))
                    cmd.Parameters.Add(New SqlParameter("@PedunculatedRemoval", 0))
                    cmd.Parameters.Add(New SqlParameter("@PedunculatedRemovalMethod", 0))
                    cmd.Parameters.Add(New SqlParameter("@PedunculatedProbably", 0))
                    cmd.Parameters.Add(New SqlParameter("@PedunculatedType", 0))
                End If

                cmd.Parameters.Add(New SqlParameter("@PedunculatedParisClass", 0))
                cmd.Parameters.Add(New SqlParameter("@PedunculatedPitPattern", 0))

                cmd.Parameters.Add(New SqlParameter("@Pseudopolyps", Pseudopolyps))
                cmd.Parameters.Add(New SqlParameter("@PseudopolypsMultiple", 0))

                If PseudopolypsQuantity.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@PseudopolypsQuantity", PseudopolypsQuantity))
                Else
                    cmd.Parameters.Add(New SqlParameter("@PseudopolypsQuantity", SqlTypes.SqlInt32.Null))
                End If

                If PolypDetails.Any(Function(x) x.PolypType.ToLower = "pseudo") Then
                    cmd.Parameters.Add(New SqlParameter("@PseudopolypsLargest", largestPolyp))
                    cmd.Parameters.Add(New SqlParameter("@PseudopolypsExcised", excisedQty))
                    cmd.Parameters.Add(New SqlParameter("@PseudopolypsSuccessful", sucessfullQty))
                    cmd.Parameters.Add(New SqlParameter("@PseudopolypsRetrieved", retreivedQty))
                    cmd.Parameters.Add(New SqlParameter("@PseudopolypsToLabs", labsQty))
                    cmd.Parameters.Add(New SqlParameter("@PseudopolypsInflam", 0))
                    cmd.Parameters.Add(New SqlParameter("@PseudopolypsPostInflam", 0))
                    cmd.Parameters.Add(New SqlParameter("@PseudopolypsRemoval", largestRemoval))
                    cmd.Parameters.Add(New SqlParameter("@PseudopolypsRemovalMethod", largestRemovalMethod))
                Else
                    cmd.Parameters.Add(New SqlParameter("@PseudopolypsLargest", SqlTypes.SqlInt32.Null))
                    cmd.Parameters.Add(New SqlParameter("@PseudopolypsExcised", SqlTypes.SqlInt32.Null))
                    cmd.Parameters.Add(New SqlParameter("@PseudopolypsSuccessful", SqlTypes.SqlInt32.Null))
                    cmd.Parameters.Add(New SqlParameter("@PseudopolypsRetrieved", SqlTypes.SqlInt32.Null))
                    cmd.Parameters.Add(New SqlParameter("@PseudopolypsToLabs", SqlTypes.SqlInt32.Null))
                    cmd.Parameters.Add(New SqlParameter("@PseudopolypsInflam", largestInflam))
                    cmd.Parameters.Add(New SqlParameter("@PseudopolypsPostInflam", largestPostInflam))
                    cmd.Parameters.Add(New SqlParameter("@PseudopolypsRemoval", 0))
                    cmd.Parameters.Add(New SqlParameter("@PseudopolypsRemovalMethod", 0))
                End If

                cmd.Parameters.Add(New SqlParameter("@Submucosal", Submucosal))
                If SubmucosalQuantity.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@SubmucosalQuantity", SubmucosalQuantity))
                Else
                    cmd.Parameters.Add(New SqlParameter("@SubmucosalQuantity", SqlTypes.SqlInt32.Null))
                End If
                If SubmucosalLargest.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@SubmucosalLargest", SubmucosalLargest))
                Else
                    cmd.Parameters.Add(New SqlParameter("@SubmucosalLargest", SqlTypes.SqlInt32.Null))
                End If
                cmd.Parameters.Add(New SqlParameter("@SubmucosalProbably", SubmucosalProbably))
                cmd.Parameters.Add(New SqlParameter("@SubmucosalType", SubmucosalType))
                cmd.Parameters.Add(New SqlParameter("@Villous", Villous))
                If VillousQuantity.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@VillousQuantity", VillousQuantity))
                Else
                    cmd.Parameters.Add(New SqlParameter("@VillousQuantity", SqlTypes.SqlInt32.Null))
                End If
                If VillousLargest.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@VillousLargest", VillousLargest))
                Else
                    cmd.Parameters.Add(New SqlParameter("@VillousLargest", SqlTypes.SqlInt32.Null))
                End If
                cmd.Parameters.Add(New SqlParameter("@VillousProbably", VillousProbably))
                cmd.Parameters.Add(New SqlParameter("@VillousType", VillousType))
                cmd.Parameters.Add(New SqlParameter("@Ulcerative", Ulcerative))
                If UlcerativeQuantity.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@UlcerativeQuantity", UlcerativeQuantity))
                Else
                    cmd.Parameters.Add(New SqlParameter("@UlcerativeQuantity", SqlTypes.SqlInt32.Null))
                End If
                If UlcerativeLargest.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@UlcerativeLargest", UlcerativeLargest))
                Else
                    cmd.Parameters.Add(New SqlParameter("@UlcerativeLargest", SqlTypes.SqlInt32.Null))
                End If
                cmd.Parameters.Add(New SqlParameter("@UlcerativeProbably", UlcerativeProbably))
                cmd.Parameters.Add(New SqlParameter("@UlcerativeType", UlcerativeType))
                cmd.Parameters.Add(New SqlParameter("@Stricturing", Stricturing))
                If StricturingQuantity.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@StricturingQuantity", StricturingQuantity))
                Else
                    cmd.Parameters.Add(New SqlParameter("@StricturingQuantity", SqlTypes.SqlInt32.Null))
                End If
                If StricturingLargest.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@StricturingLargest", StricturingLargest))
                Else
                    cmd.Parameters.Add(New SqlParameter("@StricturingLargest", SqlTypes.SqlInt32.Null))
                End If
                cmd.Parameters.Add(New SqlParameter("@StricturingProbably", StricturingProbably))
                cmd.Parameters.Add(New SqlParameter("@StricturingType", StricturingType))
                cmd.Parameters.Add(New SqlParameter("@Polypoidal", Polypoidal))
                If PolypoidalQuantity.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@PolypoidalQuantity", PolypoidalQuantity))
                Else
                    cmd.Parameters.Add(New SqlParameter("@PolypoidalQuantity", SqlTypes.SqlInt32.Null))
                End If
                If PolypoidalLargest.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@PolypoidalLargest", PolypoidalLargest))
                Else
                    cmd.Parameters.Add(New SqlParameter("@PolypoidalLargest", SqlTypes.SqlInt32.Null))
                End If
                cmd.Parameters.Add(New SqlParameter("@PolypoidalProbably", PolypoidalProbably))
                cmd.Parameters.Add(New SqlParameter("@PolypoidalType", PolypoidalType))

                cmd.Parameters.Add(New SqlParameter("@Granuloma", Granuloma))
                If GranulomaQuantity.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@GranulomaQuantity", GranulomaQuantity))
                Else
                    cmd.Parameters.Add(New SqlParameter("@GranulomaQuantity", SqlTypes.SqlInt32.Null))
                End If
                If GranulomaLargest.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@GranulomaLargest", GranulomaLargest))
                Else
                    cmd.Parameters.Add(New SqlParameter("@GranulomaLargest", SqlTypes.SqlInt32.Null))
                End If

                'MH added on 25 Oct 2021
                cmd.Parameters.Add(New SqlParameter("@FundicGlandPolyp", FundicGlandPolyp))
                If FundicGlandPolypQuantity.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@FundicGlandPolypQuantity", FundicGlandPolypQuantity))
                Else
                    cmd.Parameters.Add(New SqlParameter("@FundicGlandPolypQuantity", 0))
                End If
                If FundicGlandPolypLargest.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@FundicGlandPolypLargest", FundicGlandPolypLargest))
                Else
                    cmd.Parameters.Add(New SqlParameter("@FundicGlandPolypLargest", 0))
                End If

                cmd.Parameters.Add(New SqlParameter("@Dysplastic", Dysplastic))
                If DysplasticQuantity.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@DysplasticQuantity", DysplasticQuantity))
                Else
                    cmd.Parameters.Add(New SqlParameter("@DysplasticQuantity", SqlTypes.SqlInt32.Null))
                End If
                If DysplasticLargest.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@DysplasticLargest", DysplasticLargest))
                Else
                    cmd.Parameters.Add(New SqlParameter("@DysplasticLargest", SqlTypes.SqlInt32.Null))
                End If
                cmd.Parameters.Add(New SqlParameter("@PneumatosisColi", PneumatosisColi))

                If Tattooed.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@Tattooed", Tattooed))
                Else
                    cmd.Parameters.Add(New SqlParameter("@Tattooed", SqlTypes.SqlBoolean.Null))
                End If

                If PreviouslyTattooed.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@PreviouslyTattooed", PreviouslyTattooed))
                Else
                    cmd.Parameters.Add(New SqlParameter("@PreviouslyTattooed", SqlTypes.SqlBoolean.Null))
                End If

                If TattooType.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@TattooType", TattooType))
                Else
                    cmd.Parameters.Add(New SqlParameter("@TattooType", SqlTypes.SqlInt32.Null))
                End If
                If TattooedQuantity.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@TattooedQty", TattooedQuantity))
                Else
                    cmd.Parameters.Add(New SqlParameter("@TattooedQty", SqlTypes.SqlInt32.Null))
                End If

                'MH added on 19 Oct 2021 

                cmd.Parameters.Add(New SqlParameter("@TattooLocationTop", TattooLocationTop))
                cmd.Parameters.Add(New SqlParameter("@TattooLocationLeft", TattooLocationLeft))
                cmd.Parameters.Add(New SqlParameter("@TattooLocationRight", TattooLocationRight))
                cmd.Parameters.Add(New SqlParameter("@TattooLocationBottom", TattooLocationBottom))


                If TattooedBy Then
                    cmd.Parameters.Add(New SqlParameter("@TattooedBy", TattooedBy))
                Else
                    cmd.Parameters.Add(New SqlParameter("@TattooedBy", SqlTypes.SqlInt32.Null))
                End If
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

                connection.Open()
                rowsAffected = CInt(cmd.ExecuteNonQuery())

                Try
                    If PolypDetails IsNot Nothing AndAlso PolypDetails.Count > 0 Then
                        Using db As New ERS.Data.GastroDbEntities
                            Dim tblPolypDetails = db.ERS_ColonAbnoPolypDetails.Where(Function(x) x.SiteId = SiteId)
                            If tblPolypDetails.Count > 0 Then
                                db.ERS_ColonAbnoPolypDetails.RemoveRange(tblPolypDetails)
                            End If

                            For Each p In PolypDetails
                                Dim tbl As New ERS.Data.ERS_ColonAbnoPolypDetails
                                With tbl
                                    .SiteId = SiteId
                                    .Size = p.Size
                                    .Excised = p.Excised
                                    .Retreived = p.Retrieved
                                    .Successful = p.Successful
                                    .Labs = p.SentToLabs
                                    .Removal = p.Removal
                                    .RemovalMethod = p.RemovalMethod
                                    .Probably = p.Probably
                                    .Type = p.TumourType
                                    .Infammatory = p.Inflammatory
                                    .PostInflammatory = p.PostInflammatory
                                    .PitPattern = p.PitPattern
                                    .ParisClass = p.ParisClassification
                                End With
                                db.ERS_ColonAbnoPolypDetails.Add(tbl)
                            Next
                            db.SaveChanges()
                            Dim da As DataAccess = New DataAccess()
                            da.Update_abnormalities_colon_lesions_summary(SiteId)
                            da.Update_sites_summary(SiteId)
                        End Using
                    End If
                Catch ex As Exception
                    LogManager.LogManagerInstance.LogError("Polyp details was not saved for site id " & SiteId, ex)
                End Try
            End Using
            Return rowsAffected

        Catch ex As Exception
            Throw ex
        End Try
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveLesionsData(ByVal SiteId As Integer,
                                    ByVal None As Boolean,
                                    ByVal Sessile As Boolean,
                                    ByVal SessileQuantity As Nullable(Of Integer),
                                    ByVal SessileLargest As Nullable(Of Integer),
                                    ByVal SessileExcised As Nullable(Of Integer),
                                    ByVal SessileSuccessful As Nullable(Of Integer),
                                    ByVal SessileRetrieved As Nullable(Of Integer),
                                    ByVal SessileToLabs As Nullable(Of Integer),
                                    ByVal SessileRemoval As Integer,
                                    ByVal SessileRemovalMethod As Integer,
                                    ByVal SessileProbably As Boolean,
                                    ByVal SessileType As Integer,
                                    ByVal SessileParisClass As Integer,
                                    ByVal SessilePitPattern As Integer,
                                    ByVal Pedunculated As Boolean,
                                    ByVal PedunculatedQuantity As Nullable(Of Integer),
                                    ByVal PedunculatedLargest As Nullable(Of Integer),
                                    ByVal PedunculatedExcised As Nullable(Of Integer),
                                    ByVal PedunculatedSuccessful As Nullable(Of Integer),
                                    ByVal PedunculatedRetrieved As Nullable(Of Integer),
                                    ByVal PedunculatedToLabs As Nullable(Of Integer),
                                    ByVal PedunculatedRemoval As Integer,
                                    ByVal PedunculatedRemovalMethod As Integer,
                                    ByVal PedunculatedProbably As Boolean,
                                    ByVal PedunculatedType As Integer,
                                    ByVal PedunculatedParisClass As Integer,
                                    ByVal PedunculatedPitPattern As Integer,
                                    ByVal Pseudopolyps As Boolean,
                                    ByVal PseudopolypsMultiple As Boolean,
                                    ByVal PseudopolypsQuantity As Nullable(Of Integer),
                                    ByVal PseudopolypsLargest As Nullable(Of Integer),
                                    ByVal PseudopolypsExcised As Nullable(Of Integer),
                                    ByVal PseudopolypsSuccessful As Nullable(Of Integer),
                                    ByVal PseudopolypsRetrieved As Nullable(Of Integer),
                                    ByVal PseudopolypsToLabs As Nullable(Of Integer),
                                    ByVal PseudopolypsInflam As Boolean,
                                    ByVal PseudopolypsPostInflam As Boolean,
                                    ByVal PseudopolypsRemoval As Integer,
                                    ByVal PseudopolypsRemovalMethod As Integer,
                                    ByVal Submucosal As Boolean,
                                    ByVal SubmucosalQuantity As Nullable(Of Integer),
                                    ByVal SubmucosalLargest As Nullable(Of Integer),
                                    ByVal SubmucosalProbably As Boolean,
                                    ByVal SubmucosalType As Integer,
                                    ByVal Villous As Boolean,
                                    ByVal VillousQuantity As Nullable(Of Integer),
                                    ByVal VillousLargest As Nullable(Of Integer),
                                    ByVal VillousProbably As Boolean,
                                    ByVal VillousType As Integer,
                                    ByVal Ulcerative As Boolean,
                                    ByVal UlcerativeQuantity As Nullable(Of Integer),
                                    ByVal UlcerativeLargest As Nullable(Of Integer),
                                    ByVal UlcerativeProbably As Boolean,
                                    ByVal UlcerativeType As Integer,
                                    ByVal Stricturing As Boolean,
                                    ByVal StricturingQuantity As Nullable(Of Integer),
                                    ByVal StricturingLargest As Nullable(Of Integer),
                                    ByVal StricturingProbably As Boolean,
                                    ByVal StricturingType As Integer,
                                    ByVal Polypoidal As Boolean,
                                    ByVal PolypoidalQuantity As Nullable(Of Integer),
                                    ByVal PolypoidalLargest As Nullable(Of Integer),
                                    ByVal PolypoidalProbably As Boolean,
                                    ByVal PolypoidalType As Integer,
                                    ByVal Granuloma As Boolean,
                                    ByVal GranulomaQuantity As Nullable(Of Integer),
                                    ByVal GranulomaLargest As Nullable(Of Integer),
                                    ByVal Dysplastic As Boolean,
                                    ByVal DysplasticQuantity As Nullable(Of Integer),
                                    ByVal DysplasticLargest As Nullable(Of Integer),
                                    ByVal PneumatosisColi As Boolean,
                                    ByVal Tattooed As Nullable(Of Boolean),
                                    ByVal PreviouslyTattooed As Nullable(Of Boolean),
                                    ByVal TattooType As Nullable(Of Integer),
                                    ByVal TattooedQuantity As Nullable(Of Integer),
                                    ByVal TattooedBy As Nullable(Of Integer)) As Integer

        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("abnormalities_colon_lesions_save", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
            cmd.Parameters.Add(New SqlParameter("@None", None))
            cmd.Parameters.Add(New SqlParameter("@Sessile", Sessile))

            If SessileQuantity.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@SessileQuantity", SessileQuantity))
            Else
                cmd.Parameters.Add(New SqlParameter("@SessileQuantity", SqlTypes.SqlInt32.Null))
            End If
            If SessileLargest.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@SessileLargest", SessileLargest))
            Else
                cmd.Parameters.Add(New SqlParameter("@SessileLargest", SqlTypes.SqlInt32.Null))
            End If
            If SessileExcised.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@SessileExcised", SessileExcised))
            Else
                cmd.Parameters.Add(New SqlParameter("@SessileExcised", SqlTypes.SqlInt32.Null))
            End If
            If SessileSuccessful.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@SessileSuccessful", SessileSuccessful))
            Else
                cmd.Parameters.Add(New SqlParameter("@SessileSuccessful", SqlTypes.SqlInt32.Null))
            End If
            If SessileRetrieved.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@SessileRetrieved", SessileRetrieved))
            Else
                cmd.Parameters.Add(New SqlParameter("@SessileRetrieved", SqlTypes.SqlInt32.Null))
            End If
            If SessileToLabs.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@SessileToLabs", SessileToLabs))
            Else
                cmd.Parameters.Add(New SqlParameter("@SessileToLabs", SqlTypes.SqlInt32.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@SessileRemoval", SessileRemoval))
            cmd.Parameters.Add(New SqlParameter("@SessileRemovalMethod", SessileRemovalMethod))
            cmd.Parameters.Add(New SqlParameter("@SessileProbably", SessileProbably))
            cmd.Parameters.Add(New SqlParameter("@SessileType", SessileType))
            cmd.Parameters.Add(New SqlParameter("@SessileParisClass", SessileParisClass))
            cmd.Parameters.Add(New SqlParameter("@SessilePitPattern", SessilePitPattern))
            cmd.Parameters.Add(New SqlParameter("@Pedunculated", Pedunculated))
            If PedunculatedQuantity.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@PedunculatedQuantity", PedunculatedQuantity))
            Else
                cmd.Parameters.Add(New SqlParameter("@PedunculatedQuantity", SqlTypes.SqlInt32.Null))
            End If
            If PedunculatedLargest.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@PedunculatedLargest", PedunculatedLargest))
            Else
                cmd.Parameters.Add(New SqlParameter("@PedunculatedLargest", SqlTypes.SqlInt32.Null))
            End If
            If PedunculatedExcised.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@PedunculatedExcised", PedunculatedExcised))
            Else
                cmd.Parameters.Add(New SqlParameter("@PedunculatedExcised", SqlTypes.SqlInt32.Null))
            End If
            If PedunculatedSuccessful.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@PedunculatedSuccessful", PedunculatedSuccessful))
            Else
                cmd.Parameters.Add(New SqlParameter("@PedunculatedSuccessful", SqlTypes.SqlInt32.Null))
            End If
            If PedunculatedRetrieved.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@PedunculatedRetrieved", PedunculatedRetrieved))
            Else
                cmd.Parameters.Add(New SqlParameter("@PedunculatedRetrieved", SqlTypes.SqlInt32.Null))
            End If
            If PedunculatedToLabs.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@PedunculatedToLabs", PedunculatedToLabs))
            Else
                cmd.Parameters.Add(New SqlParameter("@PedunculatedToLabs", SqlTypes.SqlInt32.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@PedunculatedRemoval", PedunculatedRemoval))
            cmd.Parameters.Add(New SqlParameter("@PedunculatedRemovalMethod", PedunculatedRemovalMethod))
            cmd.Parameters.Add(New SqlParameter("@PedunculatedProbably", PedunculatedProbably))
            cmd.Parameters.Add(New SqlParameter("@PedunculatedType", PedunculatedType))
            cmd.Parameters.Add(New SqlParameter("@PedunculatedParisClass", PedunculatedParisClass))
            cmd.Parameters.Add(New SqlParameter("@PedunculatedPitPattern", PedunculatedPitPattern))
            cmd.Parameters.Add(New SqlParameter("@Pseudopolyps", Pseudopolyps))
            cmd.Parameters.Add(New SqlParameter("@PseudopolypsMultiple", PseudopolypsMultiple))
            If PseudopolypsQuantity.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@PseudopolypsQuantity", PseudopolypsQuantity))
            Else
                cmd.Parameters.Add(New SqlParameter("@PseudopolypsQuantity", SqlTypes.SqlInt32.Null))
            End If
            If PseudopolypsLargest.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@PseudopolypsLargest", PseudopolypsLargest))
            Else
                cmd.Parameters.Add(New SqlParameter("@PseudopolypsLargest", SqlTypes.SqlInt32.Null))
            End If
            If PseudopolypsExcised.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@PseudopolypsExcised", PseudopolypsExcised))
            Else
                cmd.Parameters.Add(New SqlParameter("@PseudopolypsExcised", SqlTypes.SqlInt32.Null))
            End If
            If PseudopolypsSuccessful.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@PseudopolypsSuccessful", PseudopolypsSuccessful))
            Else
                cmd.Parameters.Add(New SqlParameter("@PseudopolypsSuccessful", SqlTypes.SqlInt32.Null))
            End If
            If PseudopolypsRetrieved.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@PseudopolypsRetrieved", PseudopolypsRetrieved))
            Else
                cmd.Parameters.Add(New SqlParameter("@PseudopolypsRetrieved", SqlTypes.SqlInt32.Null))
            End If
            If PseudopolypsToLabs.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@PseudopolypsToLabs", PseudopolypsToLabs))
            Else
                cmd.Parameters.Add(New SqlParameter("@PseudopolypsToLabs", SqlTypes.SqlInt32.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@PseudopolypsInflam", PseudopolypsInflam))
            cmd.Parameters.Add(New SqlParameter("@PseudopolypsPostInflam", PseudopolypsPostInflam))
            cmd.Parameters.Add(New SqlParameter("@PseudopolypsRemoval", PseudopolypsRemoval))
            cmd.Parameters.Add(New SqlParameter("@PseudopolypsRemovalMethod", PseudopolypsRemovalMethod))
            cmd.Parameters.Add(New SqlParameter("@Submucosal", Submucosal))
            If SubmucosalQuantity.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@SubmucosalQuantity", SubmucosalQuantity))
            Else
                cmd.Parameters.Add(New SqlParameter("@SubmucosalQuantity", SqlTypes.SqlInt32.Null))
            End If
            If SubmucosalLargest.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@SubmucosalLargest", SubmucosalLargest))
            Else
                cmd.Parameters.Add(New SqlParameter("@SubmucosalLargest", SqlTypes.SqlInt32.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@SubmucosalProbably", SubmucosalProbably))
            cmd.Parameters.Add(New SqlParameter("@SubmucosalType", SubmucosalType))
            cmd.Parameters.Add(New SqlParameter("@Villous", Villous))
            If VillousQuantity.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@VillousQuantity", VillousQuantity))
            Else
                cmd.Parameters.Add(New SqlParameter("@VillousQuantity", SqlTypes.SqlInt32.Null))
            End If
            If VillousLargest.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@VillousLargest", VillousLargest))
            Else
                cmd.Parameters.Add(New SqlParameter("@VillousLargest", SqlTypes.SqlInt32.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@VillousProbably", VillousProbably))
            cmd.Parameters.Add(New SqlParameter("@VillousType", VillousType))
            cmd.Parameters.Add(New SqlParameter("@Ulcerative", Ulcerative))
            If UlcerativeQuantity.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@UlcerativeQuantity", UlcerativeQuantity))
            Else
                cmd.Parameters.Add(New SqlParameter("@UlcerativeQuantity", SqlTypes.SqlInt32.Null))
            End If
            If UlcerativeLargest.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@UlcerativeLargest", UlcerativeLargest))
            Else
                cmd.Parameters.Add(New SqlParameter("@UlcerativeLargest", SqlTypes.SqlInt32.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@UlcerativeProbably", UlcerativeProbably))
            cmd.Parameters.Add(New SqlParameter("@UlcerativeType", UlcerativeType))
            cmd.Parameters.Add(New SqlParameter("@Stricturing", Stricturing))
            If StricturingQuantity.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@StricturingQuantity", StricturingQuantity))
            Else
                cmd.Parameters.Add(New SqlParameter("@StricturingQuantity", SqlTypes.SqlInt32.Null))
            End If
            If StricturingLargest.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@StricturingLargest", StricturingLargest))
            Else
                cmd.Parameters.Add(New SqlParameter("@StricturingLargest", SqlTypes.SqlInt32.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@StricturingProbably", StricturingProbably))
            cmd.Parameters.Add(New SqlParameter("@StricturingType", StricturingType))
            cmd.Parameters.Add(New SqlParameter("@Polypoidal", Polypoidal))
            If PolypoidalQuantity.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@PolypoidalQuantity", PolypoidalQuantity))
            Else
                cmd.Parameters.Add(New SqlParameter("@PolypoidalQuantity", SqlTypes.SqlInt32.Null))
            End If
            If PolypoidalLargest.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@PolypoidalLargest", PolypoidalLargest))
            Else
                cmd.Parameters.Add(New SqlParameter("@PolypoidalLargest", SqlTypes.SqlInt32.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@PolypoidalProbably", PolypoidalProbably))
            cmd.Parameters.Add(New SqlParameter("@PolypoidalType", PolypoidalType))
            cmd.Parameters.Add(New SqlParameter("@Granuloma", Granuloma))
            If GranulomaQuantity.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@GranulomaQuantity", GranulomaQuantity))
            Else
                cmd.Parameters.Add(New SqlParameter("@GranulomaQuantity", SqlTypes.SqlInt32.Null))
            End If
            If GranulomaLargest.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@GranulomaLargest", GranulomaLargest))
            Else
                cmd.Parameters.Add(New SqlParameter("@GranulomaLargest", SqlTypes.SqlInt32.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@Dysplastic", Dysplastic))
            If DysplasticQuantity.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@DysplasticQuantity", DysplasticQuantity))
            Else
                cmd.Parameters.Add(New SqlParameter("@DysplasticQuantity", SqlTypes.SqlInt32.Null))
            End If
            If DysplasticLargest.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@DysplasticLargest", DysplasticLargest))
            Else
                cmd.Parameters.Add(New SqlParameter("@DysplasticLargest", SqlTypes.SqlInt32.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@PneumatosisColi", PneumatosisColi))

            If Tattooed.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@Tattooed", Tattooed))
            Else
                cmd.Parameters.Add(New SqlParameter("@Tattooed", SqlTypes.SqlBoolean.Null))
            End If

            If PreviouslyTattooed.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@PreviouslyTattooed", PreviouslyTattooed))
            Else
                cmd.Parameters.Add(New SqlParameter("@PreviouslyTattooed", SqlTypes.SqlBoolean.Null))
            End If

            If TattooType.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@TattooType", TattooType))
            Else
                cmd.Parameters.Add(New SqlParameter("@TattooType", SqlTypes.SqlInt32.Null))
            End If
            If TattooedQuantity.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@TattooedQty", TattooedQuantity))
            Else
                cmd.Parameters.Add(New SqlParameter("@TattooedQty", SqlTypes.SqlInt32.Null))
            End If
            If TattooedBy Then
                cmd.Parameters.Add(New SqlParameter("@TattooedBy", TattooedBy))
            Else
                cmd.Parameters.Add(New SqlParameter("@TattooedBy", SqlTypes.SqlInt32.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

            connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())

            'Check if record exists in therapeutics table for current site, if so update 'Markings' data

        End Using

        Return rowsAffected
    End Function
#End Region

#Region "Haemorrhage"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetHaemorrhageData(ByVal siteId As Integer) As DataTable
        Dim da As New DataAccess
        Return da.GetAbnormalities(siteId, "ERS_ColonAbnoHaemorrhage")
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveHaemorrhageData(ByVal SiteId As Integer,
                                    ByVal None As Boolean,
                                    ByVal Artificial As Boolean,
                                    ByVal Lesions As Boolean,
                                    ByVal Melaena As Boolean,
                                    ByVal Mucosal As Boolean,
                                    ByVal Purpura As Boolean,
                                    ByVal Transported As Boolean) As Integer


        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("abnormalities_colon_haemorrhage_save", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
            cmd.Parameters.Add(New SqlParameter("@None", None))
            cmd.Parameters.Add(New SqlParameter("@Artificial", Artificial))
            cmd.Parameters.Add(New SqlParameter("@Lesions", Lesions))
            cmd.Parameters.Add(New SqlParameter("@Melaena", Melaena))
            cmd.Parameters.Add(New SqlParameter("@Mucosal", Mucosal))
            cmd.Parameters.Add(New SqlParameter("@Purpura", Purpura))
            cmd.Parameters.Add(New SqlParameter("@Transported", Transported))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))
            connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function
#End Region


#Region "Vascularity"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetVascularityData(ByVal siteId As Integer) As DataTable
        Dim da As New DataAccess
        Return da.GetAbnormalities(siteId, "ERS_ColonAbnoVascularity")
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveVascularityData(ByVal SiteId As Integer,
                                        ByVal None As Boolean,
                                        ByVal Indistinct As Boolean,
                                        ByVal Exaggerated As Boolean,
                                        ByVal Attenuated As Boolean,
                                        ByVal Telangeiectasia As Boolean,
                                        ByVal TelangeiectasiaMultiple As Boolean,
                                        ByVal TelangeiectasiaQuantity As Nullable(Of Integer),
                                        ByVal Angiodysplasia As Boolean,
                                        ByVal AngiodysplasiaMultiple As Boolean,
                                        ByVal AngiodysplasiaQuantity As Nullable(Of Integer),
                                        ByVal AngiodysplasiaSize As Nullable(Of Integer),
                                        ByVal RadiationProtitis As Boolean) As Integer

        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("abnormalities_colon_vascularity_save", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
            cmd.Parameters.Add(New SqlParameter("@None", None))
            cmd.Parameters.Add(New SqlParameter("@Indistinct", Indistinct))
            cmd.Parameters.Add(New SqlParameter("@Exaggerated", Exaggerated))
            cmd.Parameters.Add(New SqlParameter("@Attenuated", Attenuated))
            cmd.Parameters.Add(New SqlParameter("@Telangeiectasia", Telangeiectasia))
            cmd.Parameters.Add(New SqlParameter("@TelangeiectasiaMultiple", TelangeiectasiaMultiple))
            If TelangeiectasiaQuantity.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@TelangeiectasiaQuantity", TelangeiectasiaQuantity))
            Else
                cmd.Parameters.Add(New SqlParameter("@TelangeiectasiaQuantity", SqlTypes.SqlDecimal.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@Angiodysplasia", Angiodysplasia))
            cmd.Parameters.Add(New SqlParameter("@AngiodysplasiaMultiple", AngiodysplasiaMultiple))
            If AngiodysplasiaQuantity.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@AngiodysplasiaQuantity", AngiodysplasiaQuantity))
            Else
                cmd.Parameters.Add(New SqlParameter("@AngiodysplasiaQuantity", SqlTypes.SqlDecimal.Null))
            End If
            If AngiodysplasiaSize.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@AngiodysplasiaSize", AngiodysplasiaSize))
            Else
                cmd.Parameters.Add(New SqlParameter("@AngiodysplasiaSize", SqlTypes.SqlDecimal.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@RadiationProtitis", RadiationProtitis))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

            Try
                connection.Open()
                rowsAffected = CInt(cmd.ExecuteNonQuery())
            Catch ex As Exception
                MsgBox(ex.ToString)
            End Try

        End Using

        Return rowsAffected
    End Function
#End Region

#Region "PerianalLesions"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetPerianalLesionsData(ByVal siteId As Integer) As DataTable
        Dim da As New DataAccess
        Return da.GetAbnormalities(siteId, "ERS_ColonAbnoPerianalLesions")
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SavePerianalLesionsData(ByVal SiteId As Integer,
                                        ByVal None As Boolean,
                                        ByVal Haemorrhoids As Boolean,
                                        ByVal FirstDegree As Boolean,
                                        ByVal SecondDegree As Boolean,
                                        ByVal ThirdDegree As Boolean,
                                        ByVal Quantity As Nullable(Of Integer),
                                        ByVal PerianalSkin As Integer,
                                        ByVal SkinTagQuantity As Integer,
                                        ByVal PerianalCancer As Boolean,
                                        ByVal PerianalWarts As Boolean,
                                        ByVal HerpesSimplex As Boolean,
                                        ByVal AnalFissure As Boolean,
                                        ByVal Acute As Boolean,
                                        ByVal Chronic As Boolean,
                                        ByVal PerianalFistula As Boolean,
                                        ByVal BandingPiles As Boolean,
                                        ByVal BandingNum As Nullable(Of Integer)
                                       ) As Integer

        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("abnormalities_colon_perianallesions_save", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
            cmd.Parameters.Add(New SqlParameter("@None", None))
            cmd.Parameters.Add(New SqlParameter("@Haemorrhoids", Haemorrhoids))
            cmd.Parameters.Add(New SqlParameter("@FirstDegree", FirstDegree))
            cmd.Parameters.Add(New SqlParameter("@SecondDegree", SecondDegree))
            cmd.Parameters.Add(New SqlParameter("@ThirdDegree", ThirdDegree))
            If Quantity.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@Quantity", Quantity))
            Else
                cmd.Parameters.Add(New SqlParameter("@Quantity", 0))
            End If

            ' cmd.Parameters.Add(New SqlParameter("@Quantity", Quantity))
            cmd.Parameters.Add(New SqlParameter("@PerianalSkin", PerianalSkin))
            cmd.Parameters.Add(New SqlParameter("@SkinTagQuantity", SkinTagQuantity))
            cmd.Parameters.Add(New SqlParameter("@PerianalCancer", PerianalCancer))
            cmd.Parameters.Add(New SqlParameter("@PerianalWarts", PerianalWarts))
            cmd.Parameters.Add(New SqlParameter("@HerpesSimplex", HerpesSimplex))
            cmd.Parameters.Add(New SqlParameter("@AnalFissure", AnalFissure))
            cmd.Parameters.Add(New SqlParameter("@Acute", Acute))
            cmd.Parameters.Add(New SqlParameter("@Chronic", Chronic))
            cmd.Parameters.Add(New SqlParameter("@PerianalFistula", PerianalFistula))
            cmd.Parameters.Add(New SqlParameter("@BandingPiles", BandingPiles))
            If BandingNum.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@BandingNum", BandingNum))
            Else
                cmd.Parameters.Add(New SqlParameter("@BandingNum", 0))
            End If
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))


            Try
                connection.Open()
                rowsAffected = CInt(cmd.ExecuteNonQuery())
            Catch ex As Exception
                MsgBox(ex.ToString)
            End Try

        End Using

        Return rowsAffected
    End Function
#End Region
End Class
