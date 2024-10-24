Imports Microsoft.VisualBasic
Imports UnisoftERS.Constants
Imports System.Data.SqlClient
Imports UnisoftERS

Public Class Abnormalities

#Region "GetAbnormalities"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetAbnormalitiesByAbnoId(EBUSAbnoDescId As Integer, storedProc As String) As DataTable
        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(storedProc, connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@EBUSAbnoDescId", EBUSAbnoDescId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function
    Public Function DeleteAbnormalities(ByVal EBUSAbnoDescId As Integer, siteId As Integer) As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("abnormalities_ebus_descriptions_delete", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@EBUSAbnoDescId", EBUSAbnoDescId))
            cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))

            cmd.Connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function
    Public Function GetAbnormalities(siteId As Integer, storedProc As String) As DataTable
        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(storedProc, connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function IsLymphNodeSite(siteId As Integer) As Boolean
        Try
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("IsLymphNodeSite", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))

                cmd.Connection.Open()
                Return cmd.ExecuteScalar()

            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error in Function: Abnormalities.IsLymphNodeSite...", ex)
            Return False
        End Try
    End Function

#End Region

#Region "Common Abnormalities"

#Region "Lesions"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetLesionsData(ByVal siteId As Integer) As DataTable
        Dim da As New Abnormalities
        Return da.GetAbnormalities(siteId, "abnormalities_common_lesions_select")
    End Function

    Public Function GetLesionsPolypData(ByVal siteId As Integer) As List(Of SitePolyps)
        Try
            Dim da As New Abnormalities
            Dim dt = da.GetAbnormalities(siteId, "abnormalities_common_polyp_details_select")

            If dt.AsEnumerable.Any(Function(x) x("SiteId") = siteId) Then
                Dim polypDetails = dt.AsEnumerable.Where(Function(x) x("SiteId") = siteId).CopyToDataTable

                If polypDetails.Rows.Count > 0 Then
                    Dim details As New List(Of SitePolyps)
                    For Each d In polypDetails.Rows
                        details.Add(New SitePolyps() With {
                            .PolypId = d("PolypDetailId"),
                            .PolypType = d("PolypType"),
                            .Size = d("Size"),
                            .Excised = d("Excised"),
                            .Retrieved = d("Retrieved"),
                            .Discarded = d("Discarded"),
                            .Successful = d("Successful"),
                            .SentToLabs = d("Labs"),
                            .Removal = d("Removal"),
                            .RemovalDescription = d("RemovalDescription"),
                            .RemovalMethod = d("RemovalMethod"),
                            .RemovalMethodDescription = d("RemovalMethodDescription"),
                            .Probably = d("Probably"),
                            .TumourType = d("Type"),
                            .TypeDescription = d("TypeDescription"),
                            .Inflammatory = d("Infammatory"),
                            .PostInflammatory = d("PostInflammatory"),
                            .PitPattern = d("PitPattern"),
                            .ParisClassification = d("ParisClass"),
                            .TattooedId = d("TattooedId"),
                            .TattooMarkingTypeId = d("TattooedMarkingTypeId"),
                            .TattooedMarkingTypeDescription = d("TattooedMarkingTypeDescription"),
                            .TattooLocationDistal = d("TattooLocationDistal"),
                            .TattooLocationProximal = d("TattooLocationProximal"),
                            .TattoDescription = d("TattoDescription"),
                            .Conditions = If(d("PolypConditionIds") IsNot DBNull.Value, d("PolypConditionIds").ToString.Split(",").Select(Function(x) Integer.Parse(x)).ToList, New List(Of Integer)),
                            .PolypTypeId = d("PolypTypeId"),
                            .SubmucosalLargest = d("SubmucosalLargest"),
                            .FocalLargest = d("FocalLargest"),
                            .FocalQuantity = d("FocalQuantity"),
                            .FundicGlandPolypLargest = d("FundicGlandPolypLargest"),
                            .FundicGlandPolypQuantity = d("FundicGlandPolypQuantity"),
                            .SubmucosalQuantity = d("SubmucosalQuantity")
                        })
                    Next

                    Return details
                Else
                    Return Nothing
                End If
            End If
        Catch ex As Exception
            Throw ex
        End Try
    End Function


    Public Function updatepolypDetails(ByVal polyp As SitePolyps, ByVal SiteId As Integer) As Boolean
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            connection.Open()

            Dim polypsRowAffected As Integer
            Try
                Dim cmd As New SqlCommand()
                cmd.Connection = connection
                cmd.CommandText = "abnormalities_common_polyp_details_update"
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Clear()
                cmd.Parameters.Add(New SqlParameter("@PolypDetailId", polyp.PolypId))
                cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
                cmd.Parameters.Add(New SqlParameter("@Size", polyp.Size))
                cmd.Parameters.Add(New SqlParameter("@Excised", polyp.Excised))
                cmd.Parameters.Add(New SqlParameter("@Retreived", polyp.Retrieved))
                cmd.Parameters.Add(New SqlParameter("@Discarded", polyp.Discarded))
                cmd.Parameters.Add(New SqlParameter("@Successful", polyp.Successful))
                cmd.Parameters.Add(New SqlParameter("@Labs", polyp.SentToLabs))
                cmd.Parameters.Add(New SqlParameter("@Removal", polyp.Removal))
                cmd.Parameters.Add(New SqlParameter("@RemovalMethod", polyp.RemovalMethod))
                cmd.Parameters.Add(New SqlParameter("@Probably", polyp.Probably))
                cmd.Parameters.Add(New SqlParameter("@Type", polyp.TumourType))
                cmd.Parameters.Add(New SqlParameter("@ParisClass", polyp.ParisClassification))
                cmd.Parameters.Add(New SqlParameter("@PitPattern", polyp.PitPattern))
                cmd.Parameters.Add(New SqlParameter("@Infammatory", polyp.Inflammatory))
                cmd.Parameters.Add(New SqlParameter("@PostInflammatory", polyp.PostInflammatory))
                cmd.Parameters.Add(New SqlParameter("@PolypConditionIds", String.Join(",", polyp.Conditions)))'new added 
                cmd.Parameters.Add(New SqlParameter("@TattooedId", polyp.TattooedId))
                cmd.Parameters.Add(New SqlParameter("@TattooMarkingTypeId", polyp.TattooMarkingTypeId))
                cmd.Parameters.Add(New SqlParameter("@TattooLocationDistal", polyp.TattooLocationDistal))
                cmd.Parameters.Add(New SqlParameter("@TattooLocationProximal", polyp.TattooLocationProximal))
                cmd.Parameters.Add(New SqlParameter("@SubmucosalQuantity", polyp.SubmucosalQuantity))
                cmd.Parameters.Add(New SqlParameter("@SubmucosalLargest", polyp.SubmucosalLargest))
                cmd.Parameters.Add(New SqlParameter("@FocalQuantity", polyp.FocalQuantity))
                cmd.Parameters.Add(New SqlParameter("@FocalLargest", polyp.FocalLargest))
                cmd.Parameters.Add(New SqlParameter("@FundicGlandPolypQuantity", polyp.FundicGlandPolypQuantity))
                cmd.Parameters.Add(New SqlParameter("@FundicGlandPolypLargest", polyp.FundicGlandPolypLargest))
                cmd.Parameters.Add(New SqlParameter("@PolypTypeId", polyp.PolypTypeId))


                cmd.ExecuteNonQuery()

                'therapy details
                cmd.CommandText = "abnormalities_common_polyp_therapy_details_save"
                cmd.Parameters.Clear()
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))
                polypsRowAffected = cmd.ExecuteNonQuery()

                If polypsRowAffected >= 0 Then

                    'specimen details   
                    cmd.CommandText = "abnormalities_common_polyp_specimen_details_save"
                    cmd.Parameters.Clear()
                    cmd.CommandType = CommandType.StoredProcedure
                    cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
                    cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))
                    polypsRowAffected = cmd.ExecuteNonQuery()
                End If

                cmd.CommandText = "abnormalities_common_lesions_summary_update"
                cmd.Parameters.Clear()
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
                cmd.ExecuteNonQuery()


            Catch ex As Exception

                Return False
            End Try
        End Using


        Return True

    End Function


    Public Function savepolypDetails(ByVal polypDetails As List(Of SitePolyps), ByVal SiteId As Integer) As Boolean
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            connection.Open()

            Dim transaction As SqlTransaction
            transaction = connection.BeginTransaction("LesionsEntryTransation") 'transaction started to undo any delete options should the process fail

            Try
                Dim cmd As SqlCommand = New SqlCommand("abnormalities_common_polyp_details_delete", connection)
                cmd.Transaction = transaction

                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
                cmd.ExecuteNonQuery()

                Dim polypsRowAffected = 0
                Dim polypDetailsId As New List(Of Integer)
                For Each polyp In polypDetails
                    cmd.CommandText = "abnormalities_common_polyp_details_save"
                    cmd.CommandType = CommandType.StoredProcedure
                    cmd.Parameters.Clear()
                    cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
                    cmd.Parameters.Add(New SqlParameter("@Size", polyp.Size))
                    cmd.Parameters.Add(New SqlParameter("@Excised", polyp.Excised))
                    cmd.Parameters.Add(New SqlParameter("@Retreived", polyp.Retrieved))
                    cmd.Parameters.Add(New SqlParameter("@Discarded", polyp.Discarded))
                    cmd.Parameters.Add(New SqlParameter("@Successful", polyp.Successful))
                    cmd.Parameters.Add(New SqlParameter("@Labs", polyp.SentToLabs))
                    cmd.Parameters.Add(New SqlParameter("@Removal", polyp.Removal))
                    cmd.Parameters.Add(New SqlParameter("@RemovalMethod", polyp.RemovalMethod))
                    cmd.Parameters.Add(New SqlParameter("@Probably", polyp.Probably))
                    cmd.Parameters.Add(New SqlParameter("@TumorTypeId", polyp.TumourType))
                    cmd.Parameters.Add(New SqlParameter("@ParisClass", polyp.ParisClassification))
                    cmd.Parameters.Add(New SqlParameter("@PitPattern", polyp.PitPattern))
                    cmd.Parameters.Add(New SqlParameter("@TattooedId", polyp.TattooedId))
                    cmd.Parameters.Add(New SqlParameter("@TattooMarkingTypeId", polyp.TattooMarkingTypeId))
                    cmd.Parameters.Add(New SqlParameter("@Infammatory", polyp.Inflammatory))
                    cmd.Parameters.Add(New SqlParameter("@PostInflammatory", polyp.PostInflammatory))
                    cmd.Parameters.Add(New SqlParameter("@PolypConditionIds", String.Join(",", polyp.Conditions)))
                    cmd.Parameters.Add(New SqlParameter("@PolypTypeId", polyp.PolypTypeId))
                    'Added by rony TFS-2970 start
                    cmd.Parameters.Add(New SqlParameter("@TattooLocationDistal", polyp.TattooLocationDistal))
                    cmd.Parameters.Add(New SqlParameter("@TattooLocationProximal", polyp.TattooLocationProximal))
                    'End

                    cmd.Parameters.Add(New SqlParameter("@SubmucosalQuantity", polyp.SubmucosalQuantity))
                    cmd.Parameters.Add(New SqlParameter("@SubmucosalLargest", polyp.SubmucosalLargest))
                    cmd.Parameters.Add(New SqlParameter("@FocalQuantity", polyp.FocalQuantity))
                    cmd.Parameters.Add(New SqlParameter("@FocalLargest", polyp.FocalLargest))
                    cmd.Parameters.Add(New SqlParameter("@FundicGlandPolypQuantity", polyp.FundicGlandPolypQuantity))
                    cmd.Parameters.Add(New SqlParameter("@FundicGlandPolypLargest", polyp.FundicGlandPolypLargest))


                    cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

                    polypsRowAffected = cmd.ExecuteNonQuery()
                Next
                'therapy details
                cmd.CommandText = "abnormalities_common_polyp_therapy_details_save"
                cmd.Parameters.Clear()
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))
                polypsRowAffected = cmd.ExecuteNonQuery()

                If polypsRowAffected >= 0 Then

                    'specimen details   
                    cmd.CommandText = "abnormalities_common_polyp_specimen_details_save"
                    cmd.Parameters.Clear()
                    cmd.CommandType = CommandType.StoredProcedure
                    cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
                    cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))
                    polypsRowAffected = cmd.ExecuteNonQuery()
                End If

                cmd.CommandText = "abnormalities_common_lesions_summary_update"
                cmd.Parameters.Clear()
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
                cmd.ExecuteNonQuery()

                transaction.Commit()
            Catch ex As Exception
                transaction.Rollback()
                Return False
            End Try
        End Using


        Return True
    End Function
    'ByVal Polyps As Boolean,
    'ByVal PolypTypeId As Integer,
    'ByVal polypDetails As List(Of SitePolyps),
    Public Function saveLesionData(ByVal SiteId As Integer,
                                    ByVal None As Boolean,
                                    ByVal Submucosal As Boolean,
                                    ByVal SubmucosalQuantity As Nullable(Of Integer),
                                    ByVal SubmucosalLargest As Nullable(Of Integer),
                                    ByVal SubmucosalProbably As Nullable(Of Boolean),
                                    ByVal SubmucosalTumorTypeId As Nullable(Of Integer),
                                    ByVal Focal As Boolean,
                                    ByVal FocalQuantity As Nullable(Of Integer),
                                    ByVal FocalLargest As Nullable(Of Integer),
                                    ByVal FocalProbably As Nullable(Of Boolean),
                                    ByVal FocalTumorTypeId As Nullable(Of Integer),
                                    ByVal Tattooed As Nullable(Of Boolean),
                                    ByVal PreviouslyTattooed As Nullable(Of Boolean),
                                    ByVal TattooType As Nullable(Of Integer),
                                    ByVal TattooedQuantity As Nullable(Of Integer),
                                    ByVal TattooedBy As Nullable(Of Integer),
                                    ByVal FundicGlandPolyp As Boolean,
                                    ByVal FundicGlandPolypQuantity As Nullable(Of Integer),
                                    ByVal FundicGlandPolypLargest As Nullable(Of Decimal),
                                    ByVal PreviousESDScar As Boolean) As Integer
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
            Dim polypsRowAffected = 0
            'If PolypDetails IsNot Nothing AndAlso PolypDetails.Count > 0 Then
            '    Dim largestPolypDetails = PolypDetails.OrderByDescending(Function(x) x.Size).FirstOrDefault
            '    largestPolyp = largestPolypDetails.Size
            '    largestRemoval = largestPolypDetails.Removal 'think.... what if the largest hasnt been removed?
            '    largestRemovalMethod = largestPolypDetails.RemovalMethod
            '    largestProbably = largestPolypDetails.Probably
            '    largestType = largestPolypDetails.TumourType
            '    largestInflam = largestPolypDetails.Inflammatory
            '    largestPostInflam = largestPolypDetails.PostInflammatory

            '    excisedQty = PolypDetails.Where(Function(x) x.Excised).Count
            '    retreivedQty = PolypDetails.Where(Function(x) x.Retrieved).Count
            '    sucessfullQty = PolypDetails.Where(Function(x) x.Successful).Count
            '    labsQty = PolypDetails.Where(Function(x) x.SentToLabs).Count
            'End If


            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                connection.Open()

                Dim transaction As SqlTransaction
                transaction = connection.BeginTransaction("LesionsEntryTransation") 'transaction started to undo any delete options should the process fail

                Try
                    Dim cmd As SqlCommand = New SqlCommand("abnormalities_common_lesions_save", connection)
                    cmd.Transaction = transaction

                    cmd.Parameters.Clear()
                    cmd.CommandType = CommandType.StoredProcedure
                    cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
                    cmd.Parameters.Add(New SqlParameter("@None", None))
                    cmd.Parameters.Add(New SqlParameter("@Polyp", False))
                    cmd.Parameters.Add(New SqlParameter("@PolypTypeId", 0))
                    cmd.Parameters.Add(New SqlParameter("@Tattooed", If(Tattooed, DBNull.Value)))
                    cmd.Parameters.Add(New SqlParameter("@PreviouslyTattooed", If(PreviouslyTattooed, DBNull.Value)))
                    cmd.Parameters.Add(New SqlParameter("@TattooType", If(TattooType, DBNull.Value)))
                    cmd.Parameters.Add(New SqlParameter("@TattooedQuantity", If(TattooedQuantity, DBNull.Value)))
                    cmd.Parameters.Add(New SqlParameter("@TattooedBy", If(TattooedBy, DBNull.Value)))
                    cmd.Parameters.Add(New SqlParameter("@Submucosal", Submucosal))
                    cmd.Parameters.Add(New SqlParameter("@SubmucosalQuantity", If(SubmucosalQuantity, DBNull.Value)))
                    cmd.Parameters.Add(New SqlParameter("@SubmucosalLargest", If(SubmucosalLargest, DBNull.Value)))
                    cmd.Parameters.Add(New SqlParameter("@SubmucosalProbably", If(SubmucosalProbably, DBNull.Value)))
                    cmd.Parameters.Add(New SqlParameter("@SubmucosalTumourTypeId", If(SubmucosalTumorTypeId, DBNull.Value)))
                    cmd.Parameters.Add(New SqlParameter("@Focal", Focal))
                    cmd.Parameters.Add(New SqlParameter("@FocalQuantity", If(FocalQuantity, DBNull.Value)))
                    cmd.Parameters.Add(New SqlParameter("@FocalLargest", If(FocalLargest, DBNull.Value)))
                    cmd.Parameters.Add(New SqlParameter("@FocalProbably", If(FocalProbably, DBNull.Value)))
                    cmd.Parameters.Add(New SqlParameter("@FocalTumourTypeId", If(FocalTumorTypeId, DBNull.Value)))
                    cmd.Parameters.Add(New SqlParameter("@FundicGlandPolyp", FundicGlandPolyp))
                    cmd.Parameters.Add(New SqlParameter("@PreviousESDScar", PreviousESDScar))
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
                    cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

                    rowsAffected = CInt(cmd.ExecuteNonQuery())


                    'therapy details
                    cmd.CommandText = "abnormalities_common_polyp_therapy_details_save"
                    cmd.Parameters.Clear()
                    cmd.CommandType = CommandType.StoredProcedure
                    cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
                    cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))
                    polypsRowAffected = cmd.ExecuteNonQuery()

                    If polypsRowAffected >= 0 Then

                        'specimen details   
                        cmd.CommandText = "abnormalities_common_polyp_specimen_details_save"
                        cmd.Parameters.Clear()
                        cmd.CommandType = CommandType.StoredProcedure
                        cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
                        cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))
                        polypsRowAffected = cmd.ExecuteNonQuery()
                    End If

                    cmd.CommandText = "abnormalities_common_lesions_summary_update"
                    cmd.Parameters.Clear()
                    cmd.CommandType = CommandType.StoredProcedure
                    cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
                    cmd.ExecuteNonQuery()

                    transaction.Commit()
                Catch ex As Exception
                    transaction.Rollback()
                    Throw ex
                End Try

            End Using

            Return rowsAffected

        Catch ex As Exception
            Throw ex
        End Try
        Return rowsAffected
    End Function

#End Region
#Region "Diverticulum"

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveDiverticulumData(ByVal SiteId As Integer,
                                    ByVal None As Boolean,
                                    ByVal Pseudodiverticulum As Boolean,
                                    ByVal Congenital1stPart As Boolean,
                                    ByVal Congenital2ndPart As Boolean,
                                    ByVal Other As Boolean,
                                    ByVal OtherDesc As String) As Integer

        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("abnormalities_diverticulum_save", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
            cmd.Parameters.Add(New SqlParameter("@None", None))
            cmd.Parameters.Add(New SqlParameter("@Pseudodiverticulum", Pseudodiverticulum))
            cmd.Parameters.Add(New SqlParameter("@Congenital1stPart", Congenital1stPart))
            cmd.Parameters.Add(New SqlParameter("@Congenital2ndPart", Congenital2ndPart))
            cmd.Parameters.Add(New SqlParameter("@Other", Other))
            cmd.Parameters.Add(New SqlParameter("@OtherDesc", OtherDesc))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

            cmd.Connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function

    Friend Function CommitEBUSite(LymphNodeRegion As String) As Integer
        Try
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("ebus_commit_site", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@LymphNodeRegion", LymphNodeRegion))
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", CInt(HttpContext.Current.Session(Constants.SESSION_PROCEDURE_ID))))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

                Try
                    Dim adapter = New SqlDataAdapter(cmd)
                    connection.Open()
                    Return CInt(cmd.ExecuteScalar())
                Catch ex As Exception
                    Throw ex
                End Try

            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error in Function: Abnormalities.CommitEBUSite...", ex)
            Return False
        End Try
    End Function
#End Region

#Region "Tumour"

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveTumourData(ByVal SiteId As Integer,
                                    ByVal None As Boolean,
                                    ByVal Type As Integer,
                                    ByVal Primary As Boolean,
                                    ByVal ExternalInvasion As Boolean) As Integer
        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("abnormalities_tumour_save", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
            cmd.Parameters.Add(New SqlParameter("@None", None))
            cmd.Parameters.Add(New SqlParameter("@Type", Type))
            cmd.Parameters.Add(New SqlParameter("@Primary", Primary))
            cmd.Parameters.Add(New SqlParameter("@ExternalInvasion", ExternalInvasion))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

            cmd.Connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function


    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveColonTumourData(ByVal SiteId As Integer,
                                    ByVal None As Boolean,
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
                                    ByVal TattooedId As Nullable(Of Integer),
                                    ByVal TattooedQuantity As Nullable(Of Integer),
                                    ByVal TattooedMarkingTypeId As Nullable(Of Integer),
                                    ByVal IsTumour As Boolean) As Integer

        Dim rowsAffected As Integer

        Try
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As SqlCommand = New SqlCommand("abnormalities_colon_tumour_save", connection)
                cmd.CommandType = CommandType.StoredProcedure

                cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
                cmd.Parameters.Add(New SqlParameter("@None", None))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))
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

                If TattooedId.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@TattooId", TattooedId))
                Else
                    cmd.Parameters.Add(New SqlParameter("@TattooId", SqlTypes.SqlInt32.Null))
                End If
                If TattooedMarkingTypeId.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@TattooMarkingTypeId", TattooedMarkingTypeId))
                Else
                    cmd.Parameters.Add(New SqlParameter("@TattooMarkingTypeId", SqlTypes.SqlInt32.Null))
                End If
                If TattooedQuantity.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@TattooQuantity", TattooedQuantity))
                Else
                    cmd.Parameters.Add(New SqlParameter("@TattooQuantity", SqlTypes.SqlInt32.Null))
                End If

                cmd.Parameters.Add(New SqlParameter("@Tumour", IsTumour))

                cmd.Connection.Open()
                rowsAffected = CInt(cmd.ExecuteNonQuery())
            End Using

            Return rowsAffected

        Catch ex As Exception
            Throw ex
        End Try

    End Function

    Public Function SaveIntrahepaticData(ByVal siteId As Integer,
                               ByVal NormalIntraheptic As Boolean,
                               ByVal SuppurativeCholangitis As Boolean,
                               ByVal IntrahepticBiliaryLeak As Boolean,
                               ByVal Tumour As Boolean,
                               ByVal IntrahepticTumourProbable As Boolean,
                               ByVal IntrahepticTumourPossible As Boolean,
                                ByVal Stones As Boolean,
                                ByVal Other As String) As Integer

        Dim rowsAffected As Integer
        Try

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As SqlCommand = New SqlCommand("abnormalities_intrahepatic_save", connection)
                cmd.CommandType = CommandType.StoredProcedure

                cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
                cmd.Parameters.Add(New SqlParameter("@NormalIntraheptic", NormalIntraheptic))
                cmd.Parameters.Add(New SqlParameter("@SuppurativeCholangitis", SuppurativeCholangitis))
                cmd.Parameters.Add(New SqlParameter("@IntrahepticBiliaryLeak", IntrahepticBiliaryLeak))
                cmd.Parameters.Add(New SqlParameter("@Tumour", Tumour))
                cmd.Parameters.Add(New SqlParameter("@TumourProbable", IntrahepticTumourProbable))
                cmd.Parameters.Add(New SqlParameter("@TumourPossible", IntrahepticTumourPossible))
                cmd.Parameters.Add(New SqlParameter("@Stones", Stones))
                cmd.Parameters.Add(New SqlParameter("@Other", Other))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

                connection.Open()
                cmd.ExecuteNonQuery()
            End Using

        Catch ex As Exception
            Throw ex
        End Try
        Return rowsAffected


    End Function
#End Region

#Region "Duodenitis"

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveDuodenitisData(ByVal SiteId As Integer,
                                    ByVal None As Boolean,
                                    ByVal Duodenitis As Boolean,
                                    ByVal Severity As Integer,
                                    ByVal Bleeding As Integer,
                                    ByVal PatchyErythema As Boolean,
                                    ByVal DiffuseErythema As Boolean,
                                    ByVal Erosions As Boolean,
                                    ByVal Nodularity As Boolean,
                                    ByVal Oedematous As Boolean) As Integer
        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("abnormalities_duodenitis_save", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
            cmd.Parameters.Add(New SqlParameter("@None", None))
            cmd.Parameters.Add(New SqlParameter("@Duodenitis", Duodenitis))
            cmd.Parameters.Add(New SqlParameter("@Severity", Severity))
            cmd.Parameters.Add(New SqlParameter("@Bleeding", Bleeding))
            cmd.Parameters.Add(New SqlParameter("@PatchyErythema", PatchyErythema))
            cmd.Parameters.Add(New SqlParameter("@DiffuseErythema", DiffuseErythema))
            cmd.Parameters.Add(New SqlParameter("@Erosions", Erosions))
            cmd.Parameters.Add(New SqlParameter("@Nodularity", Nodularity))
            cmd.Parameters.Add(New SqlParameter("@Oedematous", Oedematous))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

            cmd.Connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function
#End Region

#Region "DuodenalUlcer"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetDuodenalUlcerData(siteId As Integer) As DataTable
        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("abnormalities_duodenalulcer_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveDuodenalUlcerData(ByVal siteId As Integer,
                                            ByVal none As Boolean,
                                            ByVal Ulcer As Boolean,
                                            ByVal UlcerType As Integer,
                                            ByVal Quantity As Integer,
                                            ByVal Largest As Decimal,
                                            ByVal VisibleVessel As Boolean,
                                            ByVal VisibleVesselType As Integer,
                                            ByVal FreshClot As Boolean,
                                            ByVal ActiveBleeding As Boolean,
                                            ByVal ActiveBleedingType As Integer,
                                            ByVal OldClot As Boolean,
                                            ByVal Perforation As Boolean,
                                            ByVal RegionalIdentifier As String) As Integer

        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("abnormalities_duodenal_ulcer_save", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
            cmd.Parameters.Add(New SqlParameter("@None", none))
            cmd.Parameters.Add(New SqlParameter("@Ulcer", Ulcer))
            cmd.Parameters.Add(New SqlParameter("@UlcerType", UlcerType))
            cmd.Parameters.Add(New SqlParameter("@Quantity", Quantity))
            cmd.Parameters.Add(New SqlParameter("@Largest", Largest))
            cmd.Parameters.Add(New SqlParameter("@VisibleVessel", VisibleVessel))
            cmd.Parameters.Add(New SqlParameter("@VisibleVesselType", VisibleVesselType))
            cmd.Parameters.Add(New SqlParameter("@FreshClot", FreshClot))
            cmd.Parameters.Add(New SqlParameter("@ActiveBleeding", ActiveBleeding))
            cmd.Parameters.Add(New SqlParameter("@ActiveBleedingType", ActiveBleedingType))
            cmd.Parameters.Add(New SqlParameter("@OldClot", OldClot))
            cmd.Parameters.Add(New SqlParameter("@Perforation", Perforation))
            cmd.Parameters.Add(New SqlParameter("@RegionalIdentifier", RegionalIdentifier))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

            connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function

#End Region

#Region "Scarring"

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveScarringData(ByVal SiteId As Integer,
                                    ByVal PylorusScar As Boolean,
                                    ByVal PyloricStenosis As Boolean,
                                    ByVal PylorusDeformity As Boolean,
                                    ByVal Psudodivert As Boolean,
                                    ByVal isPylorus As Boolean) As Integer

        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("abnormalities_scaring_save", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
            'Pylorus
            cmd.Parameters.Add(New SqlParameter("@PylorusNotEntered", IIf(isPylorus, Psudodivert, 0)))
            cmd.Parameters.Add(New SqlParameter("@PylorusScar", IIf(isPylorus, PylorusScar, 0)))
            cmd.Parameters.Add(New SqlParameter("@PyloricStenosis", IIf(isPylorus, PyloricStenosis, 0)))
            cmd.Parameters.Add(New SqlParameter("@PylorusDeformity", IIf(isPylorus, PylorusDeformity, 0)))
            'Duodenum
            cmd.Parameters.Add(New SqlParameter("@DuodUlcerScar", IIf(isPylorus, 0, PylorusScar)))
            cmd.Parameters.Add(New SqlParameter("@DuodDeformity", IIf(isPylorus, 0, PylorusDeformity)))
            cmd.Parameters.Add(New SqlParameter("@DuodStenosis", IIf(isPylorus, 0, PyloricStenosis)))
            cmd.Parameters.Add(New SqlParameter("@DuodPsudodivert", IIf(isPylorus, 0, Psudodivert)))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

            cmd.Connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function
#End Region

#Region "AtrophicDuodenum"

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveAtrophicDuodenumData(ByVal SiteId As Integer,
                                    ByVal None As Boolean,
                                    ByVal Type As Integer) As Integer

        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("abnormalities_atrophic_save", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
            cmd.Parameters.Add(New SqlParameter("@None", None))
            cmd.Parameters.Add(New SqlParameter("@Type", Type))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))


            cmd.Connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function
#End Region

#Region "Vascular Lesions"
    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetVascularLesionsData(siteId As Integer) As DataTable
    '    Dim dsResult As New DataSet

    '    Using connection As New SqlConnection(DataAccess.ConnectionStr)
    '        Dim cmd As New SqlCommand("abnormalities_vascular_lesions_select", connection)
    '        cmd.CommandType = CommandType.StoredProcedure
    '        cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
    '        Dim adapter = New SqlDataAdapter(cmd)

    '        connection.Open()
    '        adapter.Fill(dsResult)
    '    End Using

    '    If dsResult.Tables.Count > 0 Then
    '        Return dsResult.Tables(0)
    '    End If
    '    Return Nothing
    'End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveVascularLesionsData(ByVal SiteId As Integer,
                                    ByVal None As Boolean,
                                    ByVal Type As Integer,
                                    ByVal Multiple As Boolean,
                                    ByVal Quantity As Nullable(Of Integer),
                                    ByVal Bleeding As Integer,
                                    ByVal Area As String) As Integer

        Dim rowsAffected As Integer
        Try

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As SqlCommand = New SqlCommand("abnormalities_vascular_lesions_save", connection)
                cmd.CommandType = CommandType.StoredProcedure

                cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
                cmd.Parameters.Add(New SqlParameter("@None", None))
                cmd.Parameters.Add(New SqlParameter("@Type", Type))
                cmd.Parameters.Add(New SqlParameter("@Multiple", Multiple))
                If Quantity.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@Quantity", Quantity))
                Else
                    cmd.Parameters.Add(New SqlParameter("@Quantity", SqlTypes.SqlInt32.Null))
                End If
                cmd.Parameters.Add(New SqlParameter("@Bleeding", Bleeding))
                cmd.Parameters.Add(New SqlParameter("@Area", Area))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

                cmd.Connection.Open()
                rowsAffected = CInt(cmd.ExecuteNonQuery())
            End Using
        Catch ex As Exception

        End Try
        Return rowsAffected
    End Function
#End Region

#End Region

#Region "Upper GI Abnormalities"

#Region "Gastritis"
    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetGastritisData(siteId As Integer) As DataTable
    '    Dim dsResult As New DataSet

    '    Using connection As New SqlConnection(DataAccess.ConnectionStr)
    '        Dim cmd As New SqlCommand("abnormalities_gastritis_select", connection)
    '        cmd.CommandType = CommandType.StoredProcedure
    '        cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
    '        Dim adapter = New SqlDataAdapter(cmd)

    '        connection.Open()
    '        adapter.Fill(dsResult)
    '    End Using

    '    If dsResult.Tables.Count > 0 Then
    '        Return dsResult.Tables(0)
    '    End If
    '    Return Nothing
    'End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveGastritisData(ByVal siteId As Integer,
                                      ByVal none As Boolean,
                                      ByVal erythematous As Boolean,
                                      ByVal erythematousSeverity As Integer,
                                      ByVal erythematousBleeding As Integer,
                                      ByVal flatErosive As Boolean,
                                      ByVal flatErosiveSeverity As Integer,
                                      ByVal flatErosiveBleeding As Integer,
                                      ByVal raisedErosive As Boolean,
                                      ByVal raisedErosiveSeverity As Integer,
                                      ByVal raisedErosiveBleeding As Integer,
                                      ByVal atrophic As Boolean,
                                      ByVal atrophicSeverity As Integer,
                                      ByVal atrophicBleeding As Integer,
                                      ByVal haemorrhagic As Boolean,
                                      ByVal haemorrhagicSeverity As Integer,
                                      ByVal haemorrhagicBleeding As Integer,
                                      ByVal reflux As Boolean,
                                      ByVal refluxSeverity As Integer,
                                      ByVal refluxBleeding As Integer,
                                      ByVal rugalHyperplastic As Boolean,
                                      ByVal rugalHyperplasticSeverity As Integer,
                                      ByVal rugalHyperplasticBleeding As Integer,
                                      ByVal vomiting As Boolean,
                                      ByVal vomitingSeverity As Integer,
                                      ByVal vomitingBleeding As Integer,
                                      ByVal corrosiveBurns As Boolean,
                                      ByVal corrosiveBurnsSeverity As Integer,
                                      ByVal corrosiveBurnsBleeding As Integer,
                                      ByVal promAreaeGastricae As Boolean,
                                      ByVal promAreaeGastricaeSeverity As Integer,
                                      ByVal intestinalMetaplasia As Boolean,
                                      ByVal intestinalMetaplasiaSeverity As Integer) As Integer

        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("abnormalities_gastritis_save", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
            cmd.Parameters.Add(New SqlParameter("@None", none))
            cmd.Parameters.Add(New SqlParameter("@Erythematous", erythematous))
            cmd.Parameters.Add(New SqlParameter("@ErythematousSeverity", erythematousSeverity))
            cmd.Parameters.Add(New SqlParameter("@ErythematousBleeding", erythematousBleeding))
            cmd.Parameters.Add(New SqlParameter("@FlatErosive", flatErosive))
            cmd.Parameters.Add(New SqlParameter("@FlatErosiveSeverity", flatErosiveSeverity))
            cmd.Parameters.Add(New SqlParameter("@FlatErosiveBleeding", flatErosiveBleeding))
            cmd.Parameters.Add(New SqlParameter("@RaisedErosive", raisedErosive))
            cmd.Parameters.Add(New SqlParameter("@RaisedErosiveSeverity", raisedErosiveSeverity))
            cmd.Parameters.Add(New SqlParameter("@RaisedErosiveBleeding", raisedErosiveBleeding))
            cmd.Parameters.Add(New SqlParameter("@Atrophic", atrophic))
            cmd.Parameters.Add(New SqlParameter("@AtrophicSeverity", atrophicSeverity))
            cmd.Parameters.Add(New SqlParameter("@AtrophicBleeding", atrophicBleeding))
            cmd.Parameters.Add(New SqlParameter("@Haemorrhagic", haemorrhagic))
            cmd.Parameters.Add(New SqlParameter("@HaemorrhagicSeverity", haemorrhagicSeverity))
            cmd.Parameters.Add(New SqlParameter("@HaemorrhagicBleeding", haemorrhagicBleeding))
            cmd.Parameters.Add(New SqlParameter("@Reflux", reflux))
            cmd.Parameters.Add(New SqlParameter("@RefluxSeverity", refluxSeverity))
            cmd.Parameters.Add(New SqlParameter("@RefluxBleeding", refluxBleeding))
            cmd.Parameters.Add(New SqlParameter("@RugalHyperplastic", rugalHyperplastic))
            cmd.Parameters.Add(New SqlParameter("@RugalHyperplasticSeverity", rugalHyperplasticSeverity))
            cmd.Parameters.Add(New SqlParameter("@RugalHyperplasticBleeding", rugalHyperplasticBleeding))
            cmd.Parameters.Add(New SqlParameter("@Vomiting", vomiting))
            cmd.Parameters.Add(New SqlParameter("@VomitingSeverity", vomitingSeverity))
            cmd.Parameters.Add(New SqlParameter("@VomitingBleeding", vomitingBleeding))
            cmd.Parameters.Add(New SqlParameter("@CorrosiveBurns", corrosiveBurns))
            cmd.Parameters.Add(New SqlParameter("@CorrosiveBurnsSeverity", corrosiveBurnsSeverity))
            cmd.Parameters.Add(New SqlParameter("@CorrosiveBurnsBleeding", corrosiveBurnsBleeding))
            cmd.Parameters.Add(New SqlParameter("@PromAreaeGastricae", promAreaeGastricae))
            cmd.Parameters.Add(New SqlParameter("@PromAreaeGastricaeSeverity", promAreaeGastricaeSeverity))
            cmd.Parameters.Add(New SqlParameter("@IntestinalMetaplasia", intestinalMetaplasia))
            cmd.Parameters.Add(New SqlParameter("@IntestinalMetaplasiaSeverity", intestinalMetaplasiaSeverity))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

            connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function

    Public Function saveSydneyProtocolData(siteId As Integer, sydneyProtocolSiteId As Integer, qty As Integer, procedureId As Integer) As Integer
        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("procedure_sydney_protocol_save", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
            cmd.Parameters.Add(New SqlParameter("@SydneyProtocolSiteId", sydneyProtocolSiteId))
            cmd.Parameters.Add(New SqlParameter("@Qty", qty))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

            connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())

            Return rowsAffected
        End Using
    End Function
#End Region

#Region "Gastric Ulcer"
    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetGastricUlcerData(siteId As Integer) As DataTable
    '    Dim dsResult As New DataSet

    '    Using connection As New SqlConnection(DataAccess.ConnectionStr)
    '        Dim cmd As New SqlCommand("abnormalities_gastric_ulcer_select", connection)
    '        cmd.CommandType = CommandType.StoredProcedure
    '        cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
    '        Dim adapter = New SqlDataAdapter(cmd)

    '        connection.Open()
    '        adapter.Fill(dsResult)
    '    End Using

    '    If dsResult.Tables.Count > 0 Then
    '        Return dsResult.Tables(0)
    '    End If
    '    Return Nothing
    'End Function

    'Public Function HadPreviousUlcer(ByVal procedureId As Integer) As Boolean
    '    Dim sql As New StringBuilder
    '    sql.Append("DECLARE @procDate DATETIME ")
    '    sql.Append("DECLARE @patientComboId VARCHAR(20) ")
    '    sql.Append("DECLARE @PatientId INT ")
    '    sql.Append("SELECT @procDate=CreatedOn,  @PatientId=PatientId FROM ERS_Procedures WHERE ProcedureId = @ProcedureId ")
    '    sql.Append("SET @patientComboId = (SELECT [Combo ID] FROM Patient WHERE [Patient No] = @PatientId) ")

    '    sql.Append(" IF EXISTS ( ")
    '    sql.Append("    SELECT 1 FROM ERS_UpperGIAbnoGastricUlcer a ")
    '    sql.Append("    JOIN ERS_Sites s ON a.SiteId = s.SiteId ")
    '    sql.Append("    JOIN ERS_Procedures p ON s.ProcedureId = p.ProcedureId ")
    '    sql.Append("    WHERE p.PatientId = @PatientId ")
    '    sql.Append("    AND p.CreatedOn < @procDate ")
    '    sql.Append("  UNION ALL ")
    '    sql.Append("    SELECT 1 FROM [AUpper GI Gastric Ulcer/Malignancy] a ")
    '    sql.Append("    JOIN Episode e ON a.[Episode No] = e.[Episode No] ")
    '    sql.Append("    WHERE a.[Patient No] = @patientComboId ")
    '    sql.Append("    AND [Episode date] < @procDate ")
    '    sql.Append(") SELECT 1 ")
    '    sql.Append("ELSE SELECT 0 ")

    '    Using connection As New SqlConnection(DataAccess.ConnectionStr)
    '        Dim cmd As New SqlCommand(sql.ToString, connection)
    '        cmd.CommandType = CommandType.Text
    '        'cmd.Parameters.Add(New SqlParameter("@PatientId", patientId))
    '        cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
    '        connection.Open()
    '        Return CBool(cmd.ExecuteScalar())
    '    End Using
    'End Function


    'Public Function GetPreviousUlcerSummary(ByVal patientId As String, ByVal procedureId As Integer) As String
    '    Dim sql As New StringBuilder
    '    sql.Append("DECLARE @procDate DATETIME, @Summary VARCHAR(4000) ")
    '    sql.Append("DECLARE @patientComboId VARCHAR(20) ")
    '    sql.Append("SELECT @procDate = CreatedOn FROM ERS_Procedures WHERE ProcedureId = @ProcedureId ")
    '    'sql.Append("SELECT @patientComboId = [Combo ID] FROM Patient WHERE [Case note no] = (SELECT CaseNoteNo FROM ERS_Patients WHERE PatientId = @PatientId) ")
    '    sql.Append("SELECT @patientComboId = [Combo ID] FROM Patient WHERE [Patient No] = @PatientId ")


    '    sql.Append("SELECT Summary AS PrevSummary, CreatedOn AS ProcDate ")
    '    sql.Append("INTO #PrevUlcers ")
    '    sql.Append("FROM ERS_UpperGIAbnoGastricUlcer a ")
    '    sql.Append("JOIN ERS_Sites s ON a.SiteId = s.SiteId ")
    '    sql.Append("JOIN ERS_Procedures p ON s.ProcedureId = p.ProcedureId ")
    '    sql.Append("WHERE p.PatientId = @PatientId ")
    '    sql.Append("AND p.CreatedOn < @procDate ")
    '    sql.Append("AND Summary IS NOT NULL ")
    '    sql.Append("    UNION ALL ")
    '    sql.Append("SELECT SummaryGastricUlcer AS PrevSummary, [Episode date] AS ProcDate ")
    '    sql.Append("FROM [AUpper GI Gastric Ulcer/Malignancy] a ")
    '    sql.Append("JOIN Episode e ON a.[Episode No] = e.[Episode No] ")
    '    sql.Append("WHERE a.[Patient No] = @patientComboId ")
    '    sql.Append("AND [Episode date] < @procDate ")
    '    sql.Append("AND SummaryGastricUlcer IS NOT NULL ")
    '    sql.Append("ORDER BY ProcDate ")

    '    sql.Append("IF EXISTS (SELECT 1 FROM #PrevUlcers) ")
    '    sql.Append("    SELECT @Summary = COALESCE(@Summary, '') ")
    '    sql.Append("    + 'Previous Gastric Ulcer recorded on ' ")
    '    sql.Append("    + CONVERT(VARCHAR, ProcDate, 101) ")
    '    sql.Append("    + ' (' + PrevSummary  + '). ' ")
    '    sql.Append("    FROM #PrevUlcers ")
    '    sql.Append("ELSE SET @Summary = '' ")
    '    sql.Append("SELECT @Summary ")

    '    Using connection As New SqlConnection(DataAccess.ConnectionStr)
    '        Dim cmd As New SqlCommand(sql.ToString, connection)
    '        cmd.CommandType = CommandType.Text
    '        cmd.Parameters.Add(New SqlParameter("@PatientId", patientId))
    '        cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
    '        connection.Open()
    '        Return CStr(cmd.ExecuteScalar())
    '    End Using
    'End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetPreviousGastricUlcer(ByVal ProcedureId As Integer, DisplayAlertOnly As Boolean) As String

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("ogd_previous_gastric_ulcer", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", ProcedureId))
            cmd.Parameters.Add(New SqlParameter("@DisplayAlertOnly", DisplayAlertOnly))
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", CInt(HttpContext.Current.Session("OperatingHospitalId"))))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            Return cmd.ExecuteScalar()
        End Using

    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveGastricUlcerData(ByVal siteId As Integer,
                                         ByVal none As Boolean,
                                         ByVal ulcer As Boolean,
                                         ByVal healingUlcer As Boolean,
                                         ByVal ulcerType As Integer,
                                         ByVal ulcerNumber As Nullable(Of Integer),
                                         ByVal ulcerLargestDiameter As Nullable(Of Decimal),
                                         ByVal ulcerActiveBleeding As Boolean,
                                         ByVal ulcerActiveBleedingType As Integer,
                                         ByVal ulcerClotInBase As Boolean,
                                         ByVal ulcerVisibleVessel As Boolean,
                                         ByVal ulcerVisibleVesselType As Integer,
                                         ByVal ulcerOldBlood As Boolean,
                                         ByVal ulcerMalignantApp As Boolean,
                                         ByVal ulcerPerforation As Boolean,
                                         ByVal healingUlcerType As Integer,
                                         ByVal notHealed As Boolean,
                                         ByVal notHealedText As String,
                                         ByVal healed As Boolean) As Integer

        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("abnormalities_gastric_ulcer_save", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
            cmd.Parameters.Add(New SqlParameter("@None", none))
            cmd.Parameters.Add(New SqlParameter("@Ulcer", ulcer))
            cmd.Parameters.Add(New SqlParameter("@HealingUlcer", healingUlcer))
            cmd.Parameters.Add(New SqlParameter("@UlcerType", ulcerType))
            If ulcerNumber.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@UlcerNumber", ulcerNumber))
            Else
                cmd.Parameters.Add(New SqlParameter("@UlcerNumber", SqlTypes.SqlInt32.Null))
            End If
            If ulcerLargestDiameter.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@UlcerLargestDiameter", ulcerLargestDiameter))
            Else
                cmd.Parameters.Add(New SqlParameter("@UlcerLargestDiameter", SqlTypes.SqlDecimal.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@UlcerActiveBleeding", ulcerActiveBleeding))
            cmd.Parameters.Add(New SqlParameter("@UlcerActiveBleedingType", ulcerActiveBleedingType))
            cmd.Parameters.Add(New SqlParameter("@UlcerClotInBase", ulcerClotInBase))
            cmd.Parameters.Add(New SqlParameter("@UlcerVisibleVessel", ulcerVisibleVessel))
            cmd.Parameters.Add(New SqlParameter("@UlcerVisibleVesselType", ulcerVisibleVesselType))
            cmd.Parameters.Add(New SqlParameter("@UlcerOldBlood", ulcerOldBlood))
            cmd.Parameters.Add(New SqlParameter("@UlcerMalignantApp", ulcerMalignantApp))
            cmd.Parameters.Add(New SqlParameter("@UlcerPerforation", ulcerPerforation))
            cmd.Parameters.Add(New SqlParameter("@HealingUlcerType", healingUlcerType))
            cmd.Parameters.Add(New SqlParameter("@NotHealed", notHealed))
            If notHealedText IsNot Nothing Then
                cmd.Parameters.Add(New SqlParameter("@NotHealedText", notHealedText))
            Else
                cmd.Parameters.Add(New SqlParameter("@NotHealedText", SqlTypes.SqlString.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@HealedUlcer", healed))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

            connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function
#End Region

#Region "Lumen"
    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetLumenData(siteId As Integer) As DataTable
    '    Dim dsResult As New DataSet

    '    Using connection As New SqlConnection(DataAccess.ConnectionStr)
    '        Dim cmd As New SqlCommand("abnormalities_lumen_select", connection)
    '        cmd.CommandType = CommandType.StoredProcedure
    '        cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
    '        Dim adapter = New SqlDataAdapter(cmd)

    '        connection.Open()
    '        adapter.Fill(dsResult)
    '    End Using

    '    If dsResult.Tables.Count > 0 Then
    '        Return dsResult.Tables(0)
    '    End If
    '    Return Nothing
    'End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveLumenData(ByVal siteId As Integer,
                                      ByVal noBlood As Boolean,
                                      ByVal freshBlood As Boolean,
                                      ByVal freshBloodAmount As Integer,
                                      ByVal freshBloodOrigin As Integer,
                                      ByVal alteredBlood As Boolean,
                                      ByVal alteredBloodAmount As Integer,
                                      ByVal alteredBloodOrigin As Integer,
                                      ByVal food As Boolean,
                                      ByVal foodAmount As Integer,
                                      ByVal bile As Boolean,
                                      ByVal bileAmount As Integer) As Integer

        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("abnormalities_lumen_save", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
            cmd.Parameters.Add(New SqlParameter("@NoBlood", noBlood))
            cmd.Parameters.Add(New SqlParameter("@FreshBlood", freshBlood))
            cmd.Parameters.Add(New SqlParameter("@FreshBloodAmount", freshBloodAmount))
            cmd.Parameters.Add(New SqlParameter("@FreshBloodOrigin", freshBloodOrigin))
            cmd.Parameters.Add(New SqlParameter("@AlteredBlood", alteredBlood))
            cmd.Parameters.Add(New SqlParameter("@AlteredBloodAmount", alteredBloodAmount))
            cmd.Parameters.Add(New SqlParameter("@AlteredBloodOrigin", alteredBloodOrigin))
            cmd.Parameters.Add(New SqlParameter("@Food", food))
            cmd.Parameters.Add(New SqlParameter("@FoodAmount", foodAmount))
            cmd.Parameters.Add(New SqlParameter("@Bile", bile))
            cmd.Parameters.Add(New SqlParameter("@BileAmount", bileAmount))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

            connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function
#End Region

#Region "Malignancy"
    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetMalignancyData(siteId As Integer) As DataTable
    '    Dim dsResult As New DataSet

    '    Using connection As New SqlConnection(DataAccess.ConnectionStr)
    '        Dim cmd As New SqlCommand("abnormalities_malignancy_select", connection)
    '        cmd.CommandType = CommandType.StoredProcedure
    '        cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
    '        Dim adapter = New SqlDataAdapter(cmd)

    '        connection.Open()
    '        adapter.Fill(dsResult)
    '    End Using

    '    If dsResult.Tables.Count > 0 Then
    '        Return dsResult.Tables(0)
    '    End If
    '    Return Nothing
    'End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveMalignancyData(ByVal siteId As Integer,
                                       ByVal none As Boolean,
                                       ByVal earlyCarcinoma As Boolean,
                                       ByVal earlyCarcinomaLesion As Integer,
                                       ByVal earlyCarcinomaStart As Nullable(Of Integer),
                                       ByVal earlyCarcinomaEnd As Nullable(Of Integer),
                                       ByVal earlyCarcinomaLargest As Nullable(Of Decimal),
                                       ByVal earlyCarcinomaBleeding As Integer,
                                       ByVal advCarcinoma As Boolean,
                                       ByVal advCarcinomaLesion As Integer,
                                       ByVal advCarcinomaStart As Nullable(Of Integer),
                                       ByVal advCarcinomaEnd As Nullable(Of Integer),
                                       ByVal advCarcinomaLargest As Nullable(Of Decimal),
                                       ByVal advCarcinomaBleeding As Integer,
                                       ByVal lymphoma As Boolean,
                                       ByVal lymphomaLesion As Decimal,
                                       ByVal lymphomaStart As Nullable(Of Integer),
                                       ByVal lymphomaEnd As Nullable(Of Integer),
                                       ByVal lymphomaLargest As Nullable(Of Decimal),
                                       ByVal lymphomaBleeding As Integer,
                                       ByVal earlyType As Integer,
                                       ByVal earlyProbably As Boolean,
                                       ByVal subEarlyType As Integer,
                                       ByVal earlyBenignOrMalignantType As Integer,
                                       ByVal earlyOtherText As String,
                                       ByVal gastricType As Integer,
                                       ByVal gastricProbably As Boolean,
                                       ByVal subGastricType As Integer,
                                       ByVal gastricBenignOrMalignantType As Integer,
                                       ByVal gastricOtherText As String,
                                       ByVal lymphomaType As Integer,
                                       ByVal lymphomaProbably As Boolean,
                                       ByVal subLymphomaType As Integer,
                                       ByVal lymphomaBenignOrMalignantType As Integer,
                                       ByVal lymphomaOtherText As String) As Integer

        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("abnormalities_malignancy_save", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
            cmd.Parameters.Add(New SqlParameter("@None", none))
            cmd.Parameters.Add(New SqlParameter("@EarlyCarcinoma", earlyCarcinoma))
            cmd.Parameters.Add(New SqlParameter("@EarlyCarcinomaLesion", earlyCarcinomaLesion))
            If earlyCarcinomaStart.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@EarlyCarcinomaStart", earlyCarcinomaStart))
            Else
                cmd.Parameters.Add(New SqlParameter("@EarlyCarcinomaStart", SqlTypes.SqlInt32.Null))
            End If
            If earlyCarcinomaEnd.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@EarlyCarcinomaEnd", earlyCarcinomaEnd))
            Else
                cmd.Parameters.Add(New SqlParameter("@EarlyCarcinomaEnd", SqlTypes.SqlInt32.Null))
            End If
            If earlyCarcinomaLargest.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@EarlyCarcinomaLargest", earlyCarcinomaLargest))
            Else
                cmd.Parameters.Add(New SqlParameter("@EarlyCarcinomaLargest", SqlTypes.SqlDecimal.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@EarlyCarcinomaBleeding", earlyCarcinomaBleeding))
            cmd.Parameters.Add(New SqlParameter("@AdvCarcinoma", advCarcinoma))
            cmd.Parameters.Add(New SqlParameter("@AdvCarcinomaLesion", advCarcinomaLesion))
            If advCarcinomaStart.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@AdvCarcinomaStart", advCarcinomaStart))
            Else
                cmd.Parameters.Add(New SqlParameter("@AdvCarcinomaStart", SqlTypes.SqlInt32.Null))
            End If
            If advCarcinomaEnd.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@AdvCarcinomaEnd", advCarcinomaEnd))
            Else
                cmd.Parameters.Add(New SqlParameter("@AdvCarcinomaEnd", SqlTypes.SqlInt32.Null))
            End If
            If advCarcinomaLargest.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@AdvCarcinomaLargest", advCarcinomaLargest))
            Else
                cmd.Parameters.Add(New SqlParameter("@AdvCarcinomaLargest", SqlTypes.SqlDecimal.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@AdvCarcinomaBleeding", advCarcinomaBleeding))
            cmd.Parameters.Add(New SqlParameter("@Lymphoma", lymphoma))
            cmd.Parameters.Add(New SqlParameter("@LymphomaLesion", lymphomaLesion))
            If lymphomaStart.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@LymphomaStart", lymphomaStart))
            Else
                cmd.Parameters.Add(New SqlParameter("@LymphomaStart", SqlTypes.SqlInt32.Null))
            End If
            If lymphomaEnd.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@LymphomaEnd", lymphomaEnd))
            Else
                cmd.Parameters.Add(New SqlParameter("@LymphomaEnd", SqlTypes.SqlInt32.Null))
            End If
            If lymphomaLargest.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@LymphomaLargest", lymphomaLargest))
            Else
                cmd.Parameters.Add(New SqlParameter("@LymphomaLargest", SqlTypes.SqlDecimal.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@LymphomaBleeding", lymphomaBleeding))

            cmd.Parameters.Add(New SqlParameter("@EarlyType", earlyType))
            cmd.Parameters.Add(New SqlParameter("@EarlyProbably", earlyProbably))
            cmd.Parameters.Add(New SqlParameter("@SubEarlyType", subEarlyType))
            cmd.Parameters.Add(New SqlParameter("@EarlyBenignOrMalignantType", earlyBenignOrMalignantType))
            cmd.Parameters.Add(New SqlParameter("@EarlyOtherText", earlyOtherText))
            cmd.Parameters.Add(New SqlParameter("@GastricType", gastricType))
            cmd.Parameters.Add(New SqlParameter("@GastricProbably", gastricProbably))
            cmd.Parameters.Add(New SqlParameter("@SubGastricType", subGastricType))
            cmd.Parameters.Add(New SqlParameter("@GastricBenignOrMalignantType", gastricBenignOrMalignantType))
            cmd.Parameters.Add(New SqlParameter("@GastricOtherText", gastricOtherText))
            cmd.Parameters.Add(New SqlParameter("@LymphomaType", lymphomaType))
            cmd.Parameters.Add(New SqlParameter("@LymphomaProbably", lymphomaProbably))
            cmd.Parameters.Add(New SqlParameter("@SubLymphomaType", subLymphomaType))
            cmd.Parameters.Add(New SqlParameter("@LymphomaBenignOrMalignantType", lymphomaBenignOrMalignantType))
            cmd.Parameters.Add(New SqlParameter("@LymphomaOtherText", lymphomaOtherText))

            connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function
#End Region

#Region "Post Surgery"
    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetPostSurgeryData(siteId As Integer) As DataTable
    '    Dim dsResult As New DataSet

    '    Using connection As New SqlConnection(DataAccess.ConnectionStr)
    '        Dim cmd As New SqlCommand("abnormalities_postsurgery_select", connection)
    '        cmd.CommandType = CommandType.StoredProcedure
    '        cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
    '        Dim adapter = New SqlDataAdapter(cmd)

    '        connection.Open()
    '        adapter.Fill(dsResult)
    '    End Using

    '    If dsResult.Tables.Count > 0 Then
    '        Return dsResult.Tables(0)
    '    End If
    '    Return Nothing
    'End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SavePostSurgeryData(ByVal siteId As Integer,
                                        ByVal none As Boolean,
                                        ByVal PreviousSurgery As Boolean,
                                        ByVal surgicalProcedure As Integer,
                                        ByVal surgicalProcedureNewItemText As String,
                                        ByVal surgicalProcedureFindings As String,
                                        ByVal duodenumPresent As Boolean,
                                        ByVal jejunumState As Integer,
                                        ByVal jejunumAbnormalText As String) As Integer

        If surgicalProcedure = -99 Then
            Dim da As New DataAccess
            Dim newId = da.InsertListItem("Surgical Procedures", surgicalProcedureNewItemText)
            If newId > 0 Then
                surgicalProcedure = newId
            End If
        End If

        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("abnormalities_postsurgery_save", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
            cmd.Parameters.Add(New SqlParameter("@None", none))
            cmd.Parameters.Add(New SqlParameter("@PreviousSurgery", PreviousSurgery))
            cmd.Parameters.Add(New SqlParameter("@SurgicalProcedure", surgicalProcedure))
            cmd.Parameters.Add(New SqlParameter("@SurgicalProcedureFindings", surgicalProcedureFindings))
            cmd.Parameters.Add(New SqlParameter("@DuodenumPresent", duodenumPresent))
            cmd.Parameters.Add(New SqlParameter("@JejunumState", jejunumState))
            cmd.Parameters.Add(New SqlParameter("@JejunumAbnormalText", jejunumAbnormalText))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

            connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function
#End Region

#Region "Polyps"
    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetPolypsData(siteId As Integer) As DataTable
    '    Dim dsResult As New DataSet

    '    Using connection As New SqlConnection(DataAccess.ConnectionStr)
    '        Dim cmd As New SqlCommand("abnormalities_polyps_select", connection)
    '        cmd.CommandType = CommandType.StoredProcedure
    '        cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
    '        Dim adapter = New SqlDataAdapter(cmd)

    '        connection.Open()
    '        adapter.Fill(dsResult)
    '    End Using

    '    If dsResult.Tables.Count > 0 Then
    '        Return dsResult.Tables(0)
    '    End If
    '    Return Nothing
    'End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SavePolypsData(ByVal siteId As Integer,
                                   ByVal None As Boolean,
                                   ByVal Sessile As Boolean,
                                   ByVal SessileType As Integer,
                                   ByVal SessileBenignType As Integer,
                                   ByVal SessileQty As Nullable(Of Integer),
                                   ByVal SessileMultiple As Boolean,
                                   ByVal SessileLargest As Nullable(Of Decimal),
                                   ByVal SessileNumExcised As Nullable(Of Integer),
                                   ByVal SessileNumRetrieved As Nullable(Of Integer),
                                   ByVal SessileNumToLabs As Nullable(Of Integer),
                                   ByVal SessileEroded As Boolean,
                                   ByVal SessileUlcerated As Boolean,
                                   ByVal SessileOverlyingClot As Boolean,
                                   ByVal SessileActiveBleeding As Boolean,
                                   ByVal SessileOverlyingOldBlood As Boolean,
                                   ByVal SessileHyperplastic As Boolean,
                                   ByVal Pedunculated As Boolean,
                                   ByVal PedunculatedType As Integer,
                                   ByVal PedunculatedBenignType As Integer,
                                   ByVal PedunculatedQty As Nullable(Of Integer),
                                   ByVal PedunculatedMultiple As Boolean,
                                   ByVal PedunculatedLargest As Nullable(Of Decimal),
                                   ByVal PedunculatedNumExcised As Nullable(Of Integer),
                                   ByVal PedunculatedNumRetrieved As Nullable(Of Integer),
                                   ByVal PedunculatedNumToLabs As Nullable(Of Integer),
                                   ByVal PedunculatedEroded As Boolean,
                                   ByVal PedunculatedUlcerated As Boolean,
                                   ByVal PedunculatedOverlyingClot As Boolean,
                                   ByVal PedunculatedActiveBleeding As Boolean,
                                   ByVal PedunculatedOverlyingOldBlood As Boolean,
                                   ByVal PedunculatedHyperplastic As Boolean,
                                   ByVal Submucosal As Boolean,
                                   ByVal SubmucosalType As Integer,
                                   ByVal SubmucosalBenignType As Integer,
                                   ByVal SubmucosalQty As Nullable(Of Integer),
                                   ByVal SubmucosalMultiple As Boolean,
                                   ByVal SubmucosalLargest As Nullable(Of Decimal),
                                   ByVal SubmucosalNumExcised As Nullable(Of Integer),
                                   ByVal SubmucosalNumRetrieved As Nullable(Of Integer),
                                   ByVal SubmucosalNumToLabs As Nullable(Of Integer),
                                   ByVal SubmucosalEroded As Boolean,
                                   ByVal SubmucosalUlcerated As Boolean,
                                   ByVal SubmucosalOverlyingClot As Boolean,
                                   ByVal SubmucosalActiveBleeding As Boolean,
                                   ByVal SubmucosalOverlyingOldBlood As Boolean,
                                   ByVal SubmucosalHyperplastic As Boolean,
                                   ByVal PolypectomyRemoval As Integer,
                                   ByVal PolypectomyRemovalType As Integer) As Integer

        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("abnormalities_polyps_save", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
            cmd.Parameters.Add(New SqlParameter("@None", None))
            cmd.Parameters.Add(New SqlParameter("@Sessile", Sessile))
            cmd.Parameters.Add(New SqlParameter("@SessileType", SessileType))
            cmd.Parameters.Add(New SqlParameter("@SessileBenignType", SessileBenignType))
            If SessileQty.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@SessileQty", SessileQty))
            Else
                cmd.Parameters.Add(New SqlParameter("@SessileQty", SqlTypes.SqlInt32.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@SessileMultiple", SessileMultiple))
            If SessileLargest.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@SessileLargest", SessileLargest))
            Else
                cmd.Parameters.Add(New SqlParameter("@SessileLargest", SqlTypes.SqlDecimal.Null))
            End If
            If SessileNumExcised.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@SessileNumExcised", SessileNumExcised))
            Else
                cmd.Parameters.Add(New SqlParameter("@SessileNumExcised", SqlTypes.SqlInt32.Null))
            End If
            If SessileNumRetrieved.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@SessileNumRetrieved", SessileNumRetrieved))
            Else
                cmd.Parameters.Add(New SqlParameter("@SessileNumRetrieved", SqlTypes.SqlInt32.Null))
            End If
            If SessileNumToLabs.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@SessileNumToLabs", SessileNumToLabs))
            Else
                cmd.Parameters.Add(New SqlParameter("@SessileNumToLabs", SqlTypes.SqlInt32.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@SessileEroded", SessileEroded))
            cmd.Parameters.Add(New SqlParameter("@SessileUlcerated", SessileUlcerated))
            cmd.Parameters.Add(New SqlParameter("@SessileOverlyingClot", SessileOverlyingClot))
            cmd.Parameters.Add(New SqlParameter("@SessileActiveBleeding", SessileActiveBleeding))
            cmd.Parameters.Add(New SqlParameter("@SessileOverlyingOldBlood", SessileOverlyingOldBlood))
            cmd.Parameters.Add(New SqlParameter("@SessileHyperplastic", SessileHyperplastic))
            cmd.Parameters.Add(New SqlParameter("@Pedunculated", Pedunculated))
            cmd.Parameters.Add(New SqlParameter("@PedunculatedType", PedunculatedType))
            cmd.Parameters.Add(New SqlParameter("@PedunculatedBenignType", PedunculatedBenignType))
            If PedunculatedQty.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@PedunculatedQty", PedunculatedQty))
            Else
                cmd.Parameters.Add(New SqlParameter("@PedunculatedQty", SqlTypes.SqlInt32.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@PedunculatedMultiple", PedunculatedMultiple))
            If PedunculatedLargest.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@PedunculatedLargest", PedunculatedLargest))
            Else
                cmd.Parameters.Add(New SqlParameter("@PedunculatedLargest", SqlTypes.SqlDecimal.Null))
            End If
            If PedunculatedNumExcised.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@PedunculatedNumExcised", PedunculatedNumExcised))
            Else
                cmd.Parameters.Add(New SqlParameter("@PedunculatedNumExcised", SqlTypes.SqlInt32.Null))
            End If
            If PedunculatedNumRetrieved.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@PedunculatedNumRetrieved", PedunculatedNumRetrieved))
            Else
                cmd.Parameters.Add(New SqlParameter("@PedunculatedNumRetrieved", SqlTypes.SqlInt32.Null))
            End If
            If PedunculatedNumToLabs.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@PedunculatedNumToLabs", PedunculatedNumToLabs))
            Else
                cmd.Parameters.Add(New SqlParameter("@PedunculatedNumToLabs", SqlTypes.SqlInt32.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@PedunculatedEroded", PedunculatedEroded))
            cmd.Parameters.Add(New SqlParameter("@PedunculatedUlcerated", PedunculatedUlcerated))
            cmd.Parameters.Add(New SqlParameter("@PedunculatedOverlyingClot", PedunculatedOverlyingClot))
            cmd.Parameters.Add(New SqlParameter("@PedunculatedActiveBleeding", PedunculatedActiveBleeding))
            cmd.Parameters.Add(New SqlParameter("@PedunculatedOverlyingOldBlood", PedunculatedOverlyingOldBlood))
            cmd.Parameters.Add(New SqlParameter("@PedunculatedHyperplastic", PedunculatedHyperplastic))
            cmd.Parameters.Add(New SqlParameter("@Submucosal", Submucosal))
            cmd.Parameters.Add(New SqlParameter("@SubmucosalType", SubmucosalType))
            cmd.Parameters.Add(New SqlParameter("@SubmucosalBenignType", SubmucosalBenignType))
            If SubmucosalQty.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@SubmucosalQty", SubmucosalQty))
            Else
                cmd.Parameters.Add(New SqlParameter("@SubmucosalQty", SqlTypes.SqlInt32.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@SubmucosalMultiple", SubmucosalMultiple))
            If SubmucosalLargest.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@SubmucosalLargest", SubmucosalLargest))
            Else
                cmd.Parameters.Add(New SqlParameter("@SubmucosalLargest", SqlTypes.SqlDecimal.Null))
            End If
            If SubmucosalNumExcised.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@SubmucosalNumExcised", SubmucosalNumExcised))
            Else
                cmd.Parameters.Add(New SqlParameter("@SubmucosalNumExcised", SqlTypes.SqlInt32.Null))
            End If
            If SubmucosalNumRetrieved.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@SubmucosalNumRetrieved", SubmucosalNumRetrieved))
            Else
                cmd.Parameters.Add(New SqlParameter("@SubmucosalNumRetrieved", SqlTypes.SqlInt32.Null))
            End If
            If SubmucosalNumToLabs.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@SubmucosalNumToLabs", SubmucosalNumToLabs))
            Else
                cmd.Parameters.Add(New SqlParameter("@SubmucosalNumToLabs", SqlTypes.SqlInt32.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@SubmucosalEroded", SubmucosalEroded))
            cmd.Parameters.Add(New SqlParameter("@SubmucosalUlcerated", SubmucosalUlcerated))
            cmd.Parameters.Add(New SqlParameter("@SubmucosalOverlyingClot", SubmucosalOverlyingClot))
            cmd.Parameters.Add(New SqlParameter("@SubmucosalActiveBleeding", SubmucosalActiveBleeding))
            cmd.Parameters.Add(New SqlParameter("@SubmucosalOverlyingOldBlood", SubmucosalOverlyingOldBlood))
            cmd.Parameters.Add(New SqlParameter("@SubmucosalHyperplastic", SubmucosalHyperplastic))

            cmd.Parameters.Add(New SqlParameter("@PolypectomyRemoval", PolypectomyRemoval))
            cmd.Parameters.Add(New SqlParameter("@PolypectomyRemovalType", PolypectomyRemovalType))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

            cmd.Connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function
#End Region

#Region "Deformity"
    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetDeformityData(siteId As Integer) As DataTable
    '    Dim dsResult As New DataSet

    '    Using connection As New SqlConnection(DataAccess.ConnectionStr)
    '        Dim cmd As New SqlCommand("abnormalities_deformity_select", connection)
    '        cmd.CommandType = CommandType.StoredProcedure
    '        cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
    '        Dim adapter = New SqlDataAdapter(cmd)

    '        connection.Open()
    '        adapter.Fill(dsResult)
    '    End Using

    '    If dsResult.Tables.Count > 0 Then
    '        Return dsResult.Tables(0)
    '    End If
    '    Return Nothing
    'End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveDeformityData(ByVal SiteId As Integer,
                                      ByVal None As Boolean,
                                      ByVal DeformityType As Integer,
                                      ByVal DeformityOther As String) As Integer

        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("abnormalities_deformity_save", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
            cmd.Parameters.Add(New SqlParameter("@None", None))
            cmd.Parameters.Add(New SqlParameter("@DeformityType", DeformityType))
            cmd.Parameters.Add(New SqlParameter("@DeformityOther", DeformityOther))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

            cmd.Connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function
#End Region

#Region "Deformity"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveMediastinalData(ByVal SiteId As Integer,
                                      ByVal None As Boolean,
                                      ByVal MediastinalType As Integer,
                                      ByVal NodeStation As String) As Integer

        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("abnormalities_mediastinal_save", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
            cmd.Parameters.Add(New SqlParameter("@None", None))
            cmd.Parameters.Add(New SqlParameter("@MediastinalType", MediastinalType))
            cmd.Parameters.Add(New SqlParameter("@NodeStation", NodeStation))

            cmd.Connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function
#End Region

#Region "Alchalasia"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveAlchalasiaData(ByVal SiteId As Integer,
                                       ByVal None As Boolean,
                                       ByVal Probable As Boolean,
                                       ByVal Confirmed As Boolean,
                                       ByVal LeadingToPerforation As Boolean)
        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("abnormalities_achalasia_save", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
            cmd.Parameters.Add(New SqlParameter("@None", None))
            cmd.Parameters.Add(New SqlParameter("@Probable", Probable))
            cmd.Parameters.Add(New SqlParameter("@Confirmed", Confirmed))
            cmd.Parameters.Add(New SqlParameter("@DilationLeadingToPerforation", LeadingToPerforation))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

            cmd.Connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using
    End Function
#End Region

#Region "Varices"
    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetVaricesData(siteId As Integer) As DataTable
    '    Dim dsResult As New DataSet

    '    Using connection As New SqlConnection(DataAccess.ConnectionStr)
    '        Dim cmd As New SqlCommand("abnormalities_varices_select", connection)
    '        cmd.CommandType = CommandType.StoredProcedure
    '        cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
    '        Dim adapter = New SqlDataAdapter(cmd)

    '        connection.Open()
    '        adapter.Fill(dsResult)
    '    End Using

    '    If dsResult.Tables.Count > 0 Then
    '        Return dsResult.Tables(0)
    '    End If
    '    Return Nothing
    'End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveVaricesData(ByVal SiteId As Integer,
                                    ByVal None As Boolean,
                                    ByVal Grading As Integer,
                                    ByVal Multiple As Boolean,
                                    ByVal Quantity As Nullable(Of Integer),
                                    ByVal Bleeding As Integer,
                                    ByVal RedSign As Integer,
                                    ByVal WhiteFibrinClot As Boolean) As Integer

        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("abnormalities_varices_save", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
            cmd.Parameters.Add(New SqlParameter("@None", None))
            cmd.Parameters.Add(New SqlParameter("@Grading", Grading))
            cmd.Parameters.Add(New SqlParameter("@Multiple", Multiple))
            If Quantity.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@Quantity", Quantity))
            Else
                cmd.Parameters.Add(New SqlParameter("@Quantity", SqlTypes.SqlInt32.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@Bleeding", Bleeding))
            cmd.Parameters.Add(New SqlParameter("@RedSign", RedSign))
            cmd.Parameters.Add(New SqlParameter("@WhiteFibrinClot", WhiteFibrinClot))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

            cmd.Connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function
#End Region

#Region "Hiatus Hernia"
    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetHiatusHerniaData(siteId As Integer) As DataTable
    '    Dim dsResult As New DataSet

    '    Using connection As New SqlConnection(DataAccess.ConnectionStr)
    '        Dim cmd As New SqlCommand("abnormalities_hiatus_hernia_select", connection)
    '        cmd.CommandType = CommandType.StoredProcedure
    '        cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
    '        Dim adapter = New SqlDataAdapter(cmd)

    '        connection.Open()
    '        adapter.Fill(dsResult)
    '    End Using

    '    If dsResult.Tables.Count > 0 Then
    '        Return dsResult.Tables(0)
    '    End If
    '    Return Nothing
    'End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveHiatusHerniaData(ByVal SiteId As Integer,
                                    ByVal None As Boolean,
                                    ByVal Sliding As Boolean,
                                    ByVal Paraoesophageal As Boolean,
                                    ByVal SlidingLength As Nullable(Of Decimal),
                                    ByVal ParaLength As Nullable(Of Decimal)) As Integer

        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("abnormalities_hiatus_hernia_save", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
            cmd.Parameters.Add(New SqlParameter("@None", None))
            cmd.Parameters.Add(New SqlParameter("@Sliding", Sliding))
            cmd.Parameters.Add(New SqlParameter("@Paraoesophageal", Paraoesophageal))
            If SlidingLength.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@SlidingLength", SlidingLength))
            Else
                cmd.Parameters.Add(New SqlParameter("@SlidingLength", SqlTypes.SqlDecimal.Null))
            End If
            If ParaLength.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@ParaLength", ParaLength))
            Else
                cmd.Parameters.Add(New SqlParameter("@ParaLength", SqlTypes.SqlDecimal.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

            'cmd.Parameters.Add(New SqlParameter("@ParaLength", ParaLength))

            cmd.Connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function
#End Region

#Region "Oesophagitis"
    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetOesophagitisData(siteId As Integer) As DataTable
    '    Dim dsResult As New DataSet

    '    Using connection As New SqlConnection(DataAccess.ConnectionStr)
    '        Dim cmd As New SqlCommand("abnormalities_oesophagitis_select", connection)
    '        cmd.CommandType = CommandType.StoredProcedure
    '        cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
    '        Dim adapter = New SqlDataAdapter(cmd)

    '        connection.Open()
    '        adapter.Fill(dsResult)
    '    End Using

    '    If dsResult.Tables.Count > 0 Then
    '        Return dsResult.Tables(0)
    '    End If
    '    Return Nothing
    'End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveOesophagitisData(ByVal SiteId As Integer,
                                    ByVal None As Boolean,
                                    ByVal MucosalAppearance As Integer,
                                    ByVal Reflux As Boolean,
                                    ByVal ActiveBleeding As Boolean,
                                    ByVal MSMGrade1 As Boolean,
                                    ByVal MSMGrade2a As Boolean,
                                    ByVal MSMGrade2b As Boolean,
                                    ByVal MSMGrade3 As Boolean,
                                    ByVal MSMGrade4 As Boolean,
                                    ByVal MSMGrade5 As Boolean,
                                    ByVal ShortOesophagus As Boolean,
                                    ByVal LAClassification As Integer,
                                    ByVal Other As Boolean,
                                    ByVal SuspectedCandida As Boolean,
                                    ByVal CausticIngestion As Boolean,
                                    ByVal SuspectedHerpes As Boolean,
                                    ByVal CorrosiveBurns As Boolean,
                                    ByVal Eosinophilic As Boolean,
                                    ByVal OtherTypeOther As Boolean,
                                    ByVal OtherTypeOtherDesc As String,
                                    ByVal SuspectedCandidaSeverity As Integer,
                                    ByVal CausticIngestionSeverity As Integer,
                                    ByVal SuspectedHerpesSeverity As Integer,
                                    ByVal EosinophilicSeverity As Integer,
                                    ByVal CorrosiveBurnsSeverity As Integer,
                                    ByVal Ulceration As Boolean,
                                    ByVal UlcerationMultiple As Boolean,
                                    ByVal UlcerationQty As Integer,
                                    ByVal UlcerationLength As Integer,
                                    ByVal UlcerationClotInBase As Boolean,
                                    ByVal UlcerationReflux As Boolean,
                                    ByVal UlcerationPostSclero As Boolean,
                                    ByVal UlcerationPostBanding As Boolean) As Integer

        If SuspectedCandida = False Then
            SuspectedCandidaSeverity = 0
        End If
        If CausticIngestion = False Then
            CausticIngestionSeverity = 0
        End If
        If SuspectedHerpes = False Then
            SuspectedHerpesSeverity = 0
        End If
        If CorrosiveBurns = False Then
            CorrosiveBurnsSeverity = 0
        End If
        If Eosinophilic = False Then
            EosinophilicSeverity = 0
        End If

        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("abnormalities_oesophagitis_save", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
            cmd.Parameters.Add(New SqlParameter("@None", None))
            cmd.Parameters.Add(New SqlParameter("@MucosalAppearance", MucosalAppearance))
            cmd.Parameters.Add(New SqlParameter("@Reflux", Reflux))
            cmd.Parameters.Add(New SqlParameter("@ActiveBleeding", ActiveBleeding))
            cmd.Parameters.Add(New SqlParameter("@MSMGrade1", MSMGrade1))
            cmd.Parameters.Add(New SqlParameter("@MSMGrade2a", MSMGrade2a))
            cmd.Parameters.Add(New SqlParameter("@MSMGrade2b", MSMGrade2b))
            cmd.Parameters.Add(New SqlParameter("@MSMGrade3", MSMGrade3))
            cmd.Parameters.Add(New SqlParameter("@MSMGrade4", MSMGrade4))
            cmd.Parameters.Add(New SqlParameter("@MSMGrade5", MSMGrade5))
            cmd.Parameters.Add(New SqlParameter("@ShortOesophagus", ShortOesophagus))
            cmd.Parameters.Add(New SqlParameter("@LAClassification", LAClassification))
            cmd.Parameters.Add(New SqlParameter("@Other", Other))
            cmd.Parameters.Add(New SqlParameter("@SuspectedCandida", SuspectedCandida))
            cmd.Parameters.Add(New SqlParameter("@CausticIngestion", CausticIngestion))
            cmd.Parameters.Add(New SqlParameter("@SuspectedHerpes", SuspectedHerpes))
            cmd.Parameters.Add(New SqlParameter("@CorrosiveBurns", CorrosiveBurns))
            cmd.Parameters.Add(New SqlParameter("@Eosinophilic", Eosinophilic))
            cmd.Parameters.Add(New SqlParameter("@OtherTypeOther", OtherTypeOther))
            cmd.Parameters.Add(New SqlParameter("@OtherTypeOtherDesc", OtherTypeOtherDesc))
            cmd.Parameters.Add(New SqlParameter("@SuspectedCandidaSeverity", SuspectedCandidaSeverity))
            cmd.Parameters.Add(New SqlParameter("@CausticIngestionSeverity", CausticIngestionSeverity))
            cmd.Parameters.Add(New SqlParameter("@SuspectedHerpesSeverity", SuspectedHerpesSeverity))
            cmd.Parameters.Add(New SqlParameter("@CorrosiveBurnsSeverity", CorrosiveBurnsSeverity))
            cmd.Parameters.Add(New SqlParameter("@EosinophilicSeverity", EosinophilicSeverity))
            cmd.Parameters.Add(New SqlParameter("@Ulceration", Ulceration))
            cmd.Parameters.Add(New SqlParameter("@UlcerationMultiple", UlcerationMultiple))
            cmd.Parameters.Add(New SqlParameter("@UlcerationQty", UlcerationQty))
            cmd.Parameters.Add(New SqlParameter("@UlcerationLength", UlcerationLength))
            cmd.Parameters.Add(New SqlParameter("@UlcerationClotInBase", UlcerationClotInBase))
            cmd.Parameters.Add(New SqlParameter("@UlcerationReflux", UlcerationReflux))
            cmd.Parameters.Add(New SqlParameter("@UlcerationPostSclero", UlcerationPostSclero))
            cmd.Parameters.Add(New SqlParameter("@UlcerationPostBanding", UlcerationPostBanding))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))


            'cmd.Parameters.Add(New SqlParameter("@Multiple", Multiple))
            'If Quantity.HasValue Then
            '    cmd.Parameters.Add(New SqlParameter("@Quantity", Quantity))
            'Else
            '    cmd.Parameters.Add(New SqlParameter("@Quantity", SqlTypes.SqlInt32.Null))
            'End If
            'cmd.Parameters.Add(New SqlParameter("@Bleeding", Bleeding))

            cmd.Connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function
#End Region

#Region "Barrett's Epithelium"
    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetBarrettEpitheliumData(siteId As Integer) As DataTable
    '    Dim dsResult As New DataSet

    '    Using connection As New SqlConnection(DataAccess.ConnectionStr)
    '        Dim cmd As New SqlCommand("abnormalities_barrett_select", connection)
    '        cmd.CommandType = CommandType.StoredProcedure
    '        cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
    '        Dim adapter = New SqlDataAdapter(cmd)

    '        connection.Open()
    '        adapter.Fill(dsResult)
    '    End Using

    '    If dsResult.Tables.Count > 0 Then
    '        Return dsResult.Tables(0)
    '    End If
    '    Return Nothing
    'End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveBarrettEpitheliumData(SiteId As Integer,
                                              None As Boolean,
                                              BarrettIslands As Boolean,
                                              Proximal As String,
                                              Distal As String,
                                              DistanceC1 As String,
                                              DistanceC2 As String,
                                              DistanceC3 As String,
                                              DistanceM1 As String,
                                              DistanceM2 As String,
                                              FocalLesions As Boolean,
                                              FocalLesionsQty As Integer,
                                              FocalLesionLargest As Integer,
                                              FocalLesionTumourTypeId As Integer,
                                              FocalLesionTumourProbably As Boolean,
                                              FocalLesionParisClassId As Integer,
                                              FocalLesionPitPatternId As Integer,
                                              InspectionTimeMins As String,
                                              SmokerRadioButtonListId As Integer) As Integer 'add by mostafiz 2360
        Dim rowsAffected As Integer
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("abnormalities_barrett_save", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
            cmd.Parameters.Add(New SqlParameter("@None", None))
            cmd.Parameters.Add(New SqlParameter("@BarrettIslands", BarrettIslands))
            If Not String.IsNullOrEmpty(Proximal) Then
                cmd.Parameters.Add(New SqlParameter("@Proximal", Proximal))
            Else
                cmd.Parameters.Add(New SqlParameter("@Proximal", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(Distal) Then
                cmd.Parameters.Add(New SqlParameter("@Distal", Distal))
            Else
                cmd.Parameters.Add(New SqlParameter("@Distal", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(DistanceC1) Then
                cmd.Parameters.Add(New SqlParameter("@DistanceC1", DistanceC1))
            Else
                cmd.Parameters.Add(New SqlParameter("@DistanceC1", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(DistanceC2) Then
                cmd.Parameters.Add(New SqlParameter("@DistanceC2", DistanceC2))
            Else
                cmd.Parameters.Add(New SqlParameter("@DistanceC2", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(DistanceC3) Then
                cmd.Parameters.Add(New SqlParameter("@DistanceC3", DistanceC3))
            Else
                cmd.Parameters.Add(New SqlParameter("@DistanceC3", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(DistanceM1) Then
                cmd.Parameters.Add(New SqlParameter("@DistanceM1", DistanceM1))
            Else
                cmd.Parameters.Add(New SqlParameter("@DistanceM1", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(DistanceM2) Then
                cmd.Parameters.Add(New SqlParameter("@DistanceM2", DistanceM2))
            Else
                cmd.Parameters.Add(New SqlParameter("@DistanceM2", SqlTypes.SqlString.Null))
            End If
            If FocalLesions Then
                cmd.Parameters.Add(New SqlParameter("@FocalLesion", FocalLesions))
            Else
                cmd.Parameters.Add(New SqlParameter("@FocalLesion", SqlTypes.SqlString.Null))
            End If
            If FocalLesions AndAlso Not String.IsNullOrEmpty(FocalLesionsQty) Then
                cmd.Parameters.Add(New SqlParameter("@FocalLesionQty", FocalLesionsQty))
            Else
                cmd.Parameters.Add(New SqlParameter("@FocalLesionQty", SqlTypes.SqlString.Null))
            End If
            If FocalLesions AndAlso Not String.IsNullOrEmpty(FocalLesionLargest) Then
                cmd.Parameters.Add(New SqlParameter("@FocalLesionLargest", FocalLesionLargest))
            Else
                cmd.Parameters.Add(New SqlParameter("@FocalLesionLargest", SqlTypes.SqlString.Null))
            End If
            If FocalLesions AndAlso Not String.IsNullOrEmpty(FocalLesionTumourTypeId) Then
                cmd.Parameters.Add(New SqlParameter("@FocalLesionTumourTypeId", FocalLesionTumourTypeId))
            Else
                cmd.Parameters.Add(New SqlParameter("@FocalLesionTumourTypeId", SqlTypes.SqlString.Null))
            End If
            If FocalLesions AndAlso Not String.IsNullOrEmpty(FocalLesionTumourProbably) Then
                cmd.Parameters.Add(New SqlParameter("@FocalLesionProbably", FocalLesionTumourProbably))
            Else
                cmd.Parameters.Add(New SqlParameter("@FocalLesionProbably", SqlTypes.SqlString.Null))
            End If
            If FocalLesions AndAlso Not String.IsNullOrEmpty(FocalLesionParisClassId) Then
                cmd.Parameters.Add(New SqlParameter("@FocalLesionParisClassificationId", FocalLesionParisClassId))
            Else
                cmd.Parameters.Add(New SqlParameter("@FocalLesionParisClassificationId", SqlTypes.SqlString.Null))
            End If
            If FocalLesions AndAlso Not String.IsNullOrEmpty(FocalLesionPitPatternId) Then
                cmd.Parameters.Add(New SqlParameter("@FocalLesionPitPatternId", FocalLesionPitPatternId))
            Else
                cmd.Parameters.Add(New SqlParameter("@FocalLesionPitPatternId", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(InspectionTimeMins) Then
                cmd.Parameters.Add(New SqlParameter("@InspectionTimeMins", InspectionTimeMins))
            Else
                cmd.Parameters.Add(New SqlParameter("@InspectionTimeMins", SqlTypes.SqlString.Null))
            End If
            'add by mostafiz 2360
            If Not String.IsNullOrEmpty(SmokerRadioButtonListId) Then
                cmd.Parameters.Add(New SqlParameter("@SmokerRadioButtonListId", SmokerRadioButtonListId))
            Else
                cmd.Parameters.Add(New SqlParameter("@SmokerRadioButtonListId", SmokerRadioButtonListId))
            End If
            'add by mostafiz 2360
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

            cmd.Connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function
#End Region

#Region "Miscellaneous"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetOgdMiscellaneousData(siteId As Integer) As DataTable
        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("abnormalities_miscellaneous_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveOgdMiscellaneousData(ByVal siteId As Integer,
                                        ByVal none As Boolean,
                                        ByVal Web As Boolean,
                                        ByVal Mallory As Boolean,
                                        ByVal SchatzkiRing As Boolean,
                                        ByVal FoodResidue As Boolean,
                                        ByVal Foreignbody As Boolean,
                                        ByVal ExtrinsicCompression As Boolean,
                                        ByVal Diverticulum As Boolean,
                                        ByVal DivertMultiple As Boolean,
                                        ByVal DivertQty As Integer,
                                        ByVal Pharyngeal As Boolean,
                                        ByVal DiffuseIntramural As Boolean,
                                        ByVal TractionType As Boolean,
                                        ByVal PulsionType As Boolean,
                                        ByVal MotilityDisorder As Boolean,
                                        ByVal ProbableAchalasia As Boolean,
                                        ByVal ConfirmedAchalasia As Boolean,
                                        ByVal Presbyoesophagus As Boolean,
                                        ByVal MarkedTertiaryContractions As Boolean,
                                        ByVal LaxLowerOesoSphincter As Boolean,
                                        ByVal TortuousOesophagus As Boolean,
                                        ByVal DilatedOesophagus As Boolean,
                                        ByVal MotilityPoor As Boolean,
                                        ByVal Stricture As Boolean,
                                        ByVal StrictureCompression As Integer,
                                        ByVal StrictureScopeNotPass As Boolean,
                                        ByVal StrictureSeverity As Integer,
                                        ByVal StrictureType As Integer,
                                        ByVal StrictureProbably As Boolean,
                                        ByVal StrictureBenignType As Integer,
                                        ByVal StrictureBeginning As Integer,
                                        ByVal StrictureLength As Integer,
                                        ByVal StricturePerforation As Integer,
                                        ByVal Tumour As Boolean,
                                        ByVal TumourType As Integer,
                                        ByVal TumourProbably As Boolean,
                                        ByVal TumourExophytic As Integer,
                                        ByVal TumourBenignType As Integer,
                                        ByVal TumourBenignTypeOther As String,
                                        ByVal TumourBeginning As Integer,
                                        ByVal TumourLength As Integer,
                                        ByVal TumourScopeNotPass As Boolean,
                                        ByVal MiscOther As String,
                                        ByVal InletPatch As Boolean,
                                        ByVal InletPatchMultiple As Boolean,
                                        ByVal InletPatchQty As Integer,
                                        ByVal Fitsula As Boolean,
                                        ByVal InletPouch As Boolean,
                                        ByVal InletPouchQty As Integer,
                                        ByVal ZLine As Boolean,
                                        ByVal ZLineSize As Integer,
                                        ByVal Volvulus As Boolean,
                                        ByVal AmpullaryAdenoma As Boolean,
                                        ByVal StentOcclusion As Boolean,
                                        ByVal StentInSitu As Boolean,
                                        ByVal PEGInSitu As Boolean) As Integer

        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("abnormalities_miscellaneous_save", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
            cmd.Parameters.Add(New SqlParameter("@None", none))
            cmd.Parameters.Add(New SqlParameter("@Web", Web))
            cmd.Parameters.Add(New SqlParameter("@Mallory", Mallory))
            cmd.Parameters.Add(New SqlParameter("@SchatzkiRing", SchatzkiRing))
            cmd.Parameters.Add(New SqlParameter("@FoodResidue", FoodResidue))
            cmd.Parameters.Add(New SqlParameter("@Foreignbody", Foreignbody))
            cmd.Parameters.Add(New SqlParameter("@ExtrinsicCompression", ExtrinsicCompression))
            cmd.Parameters.Add(New SqlParameter("@Diverticulum", Diverticulum))
            cmd.Parameters.Add(New SqlParameter("@DivertMultiple", DivertMultiple))
            cmd.Parameters.Add(New SqlParameter("@DivertQty", DivertQty))
            cmd.Parameters.Add(New SqlParameter("@Pharyngeal", Pharyngeal))
            cmd.Parameters.Add(New SqlParameter("@DiffuseIntramural", DiffuseIntramural))
            cmd.Parameters.Add(New SqlParameter("@TractionType", TractionType))
            cmd.Parameters.Add(New SqlParameter("@PulsionType", PulsionType))
            cmd.Parameters.Add(New SqlParameter("@MotilityDisorder", MotilityDisorder))
            cmd.Parameters.Add(New SqlParameter("@ProbableAchalasia", ProbableAchalasia))
            cmd.Parameters.Add(New SqlParameter("@ConfirmedAchalasia", ConfirmedAchalasia))
            cmd.Parameters.Add(New SqlParameter("@Presbyoesophagus", Presbyoesophagus))
            cmd.Parameters.Add(New SqlParameter("@MarkedTertiaryContractions", MarkedTertiaryContractions))
            cmd.Parameters.Add(New SqlParameter("@LaxLowerOesoSphincter", LaxLowerOesoSphincter))
            cmd.Parameters.Add(New SqlParameter("@TortuousOesophagus", TortuousOesophagus))
            cmd.Parameters.Add(New SqlParameter("@DilatedOesophagus", DilatedOesophagus))
            cmd.Parameters.Add(New SqlParameter("@MotilityPoor", MotilityPoor))
            cmd.Parameters.Add(New SqlParameter("@Stricture", Stricture))
            cmd.Parameters.Add(New SqlParameter("@StrictureCompression", StrictureCompression))
            cmd.Parameters.Add(New SqlParameter("@StrictureScopeNotPass", StrictureScopeNotPass))
            cmd.Parameters.Add(New SqlParameter("@StrictureSeverity", StrictureSeverity))
            cmd.Parameters.Add(New SqlParameter("@StrictureType", StrictureType))
            cmd.Parameters.Add(New SqlParameter("@StrictureProbably", StrictureProbably))
            cmd.Parameters.Add(New SqlParameter("@StrictureBenignType", StrictureBenignType))
            cmd.Parameters.Add(New SqlParameter("@StrictureBeginning", StrictureBeginning))
            cmd.Parameters.Add(New SqlParameter("@StrictureLength", StrictureLength))
            cmd.Parameters.Add(New SqlParameter("@StricturePerforation", StricturePerforation))
            cmd.Parameters.Add(New SqlParameter("@Tumour", Tumour))
            cmd.Parameters.Add(New SqlParameter("@TumourType", TumourType))
            cmd.Parameters.Add(New SqlParameter("@TumourProbably", TumourProbably))
            cmd.Parameters.Add(New SqlParameter("@TumourExophytic", TumourExophytic))
            cmd.Parameters.Add(New SqlParameter("@TumourBenignType", TumourBenignType))
            cmd.Parameters.Add(New SqlParameter("@TumourBenignTypeOther", IIf(TumourBenignTypeOther Is Nothing, "", TumourBenignTypeOther))) 'TumourBenignTypeOther))
            cmd.Parameters.Add(New SqlParameter("@TumourBeginning", TumourBeginning))
            cmd.Parameters.Add(New SqlParameter("@TumourLength", TumourLength))
            cmd.Parameters.Add(New SqlParameter("@TumourScopeCouldNotPass", TumourScopeNotPass))
            cmd.Parameters.Add(New SqlParameter("@MiscOther", IIf(MiscOther Is Nothing, "", MiscOther.Replace("<", "&lt;").Replace(">", "&gt;"))))
            cmd.Parameters.Add(New SqlParameter("@InletPatch", InletPatch))
            cmd.Parameters.Add(New SqlParameter("@InletPatchMultiple", InletPatchMultiple))
            cmd.Parameters.Add(New SqlParameter("@InletPatchQty", InletPatchQty))
            cmd.Parameters.Add(New SqlParameter("@Fitsula", Fitsula))
            cmd.Parameters.Add(New SqlParameter("@InletPouch", InletPouch))
            cmd.Parameters.Add(New SqlParameter("@InletPouchQty", InletPouchQty))
            cmd.Parameters.Add(New SqlParameter("@ZLine", ZLine))
            cmd.Parameters.Add(New SqlParameter("@ZLineSize", ZLineSize))
            cmd.Parameters.Add(New SqlParameter("@Volvulus", Volvulus))
            cmd.Parameters.Add(New SqlParameter("@AmpullaryAdenoma", AmpullaryAdenoma))
            cmd.Parameters.Add(New SqlParameter("@StentOcclusion", StentOcclusion))
            cmd.Parameters.Add(New SqlParameter("@StentInSitu", StentInSitu))
            cmd.Parameters.Add(New SqlParameter("@PEGInSitu", PEGInSitu))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))



            connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function



#End Region

#Region "Tumour"
    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    'Public Function GetOgdTumourData(siteId As Integer) As DataTable
    '    Dim dsResult As New DataSet

    '    Using connection As New SqlConnection(DataAccess.ConnectionStr)
    '        Dim cmd As New SqlCommand("abnormalities_tumour_select", connection)
    '        cmd.CommandType = CommandType.StoredProcedure
    '        cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
    '        Dim adapter = New SqlDataAdapter(cmd)

    '        connection.Open()
    '        adapter.Fill(dsResult)
    '    End Using

    '    If dsResult.Tables.Count > 0 Then
    '        Return dsResult.Tables(0)
    '    End If
    '    Return Nothing
    'End Function

    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    'Public Function SaveOgdTumourData(ByVal siteId As Integer,
    '                                    ByVal None As Boolean,
    '                                    ByVal Type As Integer,
    '                                    ByVal Primary As Boolean,
    '                                    ByVal ExternalInvasion As Boolean,
    '                                    ByVal Tumour As Boolean,
    '                                    ByVal TumourProbably As Boolean,
    '                                    ByVal TumourExophytic As Integer,
    '                                    ByVal TumourBenignType As Integer,
    '                                    ByVal TumourBenignTypeOther As String,
    '                                    ByVal TumourBeginning As Integer,
    '                                    ByVal TumourLength As Integer,
    '                                    ByVal TumourOther As String,
    '                                    ByVal TumourScopeNotPass As Boolean)

    '    Dim rowsAffected As Integer

    '    Using connection As New SqlConnection(DataAccess.ConnectionStr)
    '        Dim cmd As SqlCommand = New SqlCommand("abnormalities_tumour_save", connection)
    '        cmd.CommandType = CommandType.StoredProcedure
    '        cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
    '        cmd.Parameters.Add(New SqlParameter("@None", None))
    '        cmd.Parameters.Add(New SqlParameter("@Type", Type))
    '        cmd.Parameters.Add(New SqlParameter("@Primary", Primary))
    '        cmd.Parameters.Add(New SqlParameter("@ExternalInvasion", ExternalInvasion))
    '        cmd.Parameters.Add(New SqlParameter("@Tumour", Tumour))
    '        cmd.Parameters.Add(New SqlParameter("@TumourProbably", TumourProbably))
    '        cmd.Parameters.Add(New SqlParameter("@TumourExophytic", TumourExophytic))
    '        cmd.Parameters.Add(New SqlParameter("@TumourBenignType", TumourBenignType))
    '        cmd.Parameters.Add(New SqlParameter("@TumourBenignTypeOther", IIf(TumourBenignTypeOther Is Nothing, "", TumourBenignTypeOther))) 'TumourBenignTypeOther))
    '        cmd.Parameters.Add(New SqlParameter("@TumourBeginning", TumourBeginning))
    '        cmd.Parameters.Add(New SqlParameter("@TumourLength", TumourLength))
    '        cmd.Parameters.Add(New SqlParameter("@TumourOther", TumourOther))

    '        Dim operatingHospitalId As Integer = CInt(HttpContext.Current.Session("OperatingHospitalID"))
    '        Dim OBda As New Options
    '        Dim bIsLAClassification As Boolean = OBda.IsLAClassification(operatingHospitalId)
    '        cmd.Parameters.Add(New SqlParameter("@IsLAClassification", bIsLAClassification))
    '        cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))
    '        cmd.Parameters.Add(New SqlParameter("@TumourScopeNotPass", TumourScopeNotPass))
    '        connection.Open()
    '        rowsAffected = CInt(cmd.ExecuteNonQuery())
    '    End Using

    '    Return rowsAffected
    'End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetOgdTumourData(siteId As Integer) As DataTable
        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("abnormalities_ogd_tumour_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveOgdTumourData(ByVal siteId As Integer,
                                        ByVal none As Boolean,
                                        ByVal Tumour As Boolean,
                                        ByVal TumourType As Integer,
                                        ByVal TumourProbably As Boolean,
                                        ByVal TumourExophytic As Integer,
                                        ByVal TumourBenignType As Integer,
                                        ByVal TumourBenignTypeOther As String,
                                        ByVal TumourBeginning As Integer,
                                        ByVal TumourLength As Integer,
                                        ByVal TumourLocation As String, 'edited by mostafiz 3487
                                        ByVal StageT As String,
                                        ByVal StageN As String,
                                        ByVal StageM As String,
                                        ByVal TumourScopeNotPass As Boolean) As Integer

        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("abnormalities_ogd_tumour_save", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
            cmd.Parameters.Add(New SqlParameter("@None", none))
            'cmd.Parameters.Add(New SqlParameter("@Web", Web))
            'cmd.Parameters.Add(New SqlParameter("@Mallory", Mallory))
            'cmd.Parameters.Add(New SqlParameter("@SchatzkiRing", SchatzkiRing))
            'cmd.Parameters.Add(New SqlParameter("@FoodResidue", FoodResidue))
            'cmd.Parameters.Add(New SqlParameter("@Foreignbody", Foreignbody))
            'cmd.Parameters.Add(New SqlParameter("@ExtrinsicCompression", ExtrinsicCompression))
            'cmd.Parameters.Add(New SqlParameter("@Diverticulum", Diverticulum))
            'cmd.Parameters.Add(New SqlParameter("@DivertMultiple", DivertMultiple))
            'cmd.Parameters.Add(New SqlParameter("@DivertQty", DivertQty))
            'cmd.Parameters.Add(New SqlParameter("@Pharyngeal", Pharyngeal))
            'cmd.Parameters.Add(New SqlParameter("@DiffuseIntramural", DiffuseIntramural))
            'cmd.Parameters.Add(New SqlParameter("@TractionType", TractionType))
            'cmd.Parameters.Add(New SqlParameter("@PulsionType", PulsionType))
            'cmd.Parameters.Add(New SqlParameter("@MotilityDisorder", MotilityDisorder))
            'cmd.Parameters.Add(New SqlParameter("@ProbableAchalasia", ProbableAchalasia))
            'cmd.Parameters.Add(New SqlParameter("@ConfirmedAchalasia", ConfirmedAchalasia))
            'cmd.Parameters.Add(New SqlParameter("@Presbyoesophagus", Presbyoesophagus))
            'cmd.Parameters.Add(New SqlParameter("@MarkedTertiaryContractions", MarkedTertiaryContractions))
            'cmd.Parameters.Add(New SqlParameter("@LaxLowerOesoSphincter", LaxLowerOesoSphincter))
            'cmd.Parameters.Add(New SqlParameter("@TortuousOesophagus", TortuousOesophagus))
            'cmd.Parameters.Add(New SqlParameter("@DilatedOesophagus", DilatedOesophagus))
            'cmd.Parameters.Add(New SqlParameter("@MotilityPoor", MotilityPoor))
            'cmd.Parameters.Add(New SqlParameter("@Ulceration", Ulceration))
            'cmd.Parameters.Add(New SqlParameter("@UlcerationType", UlcerationType))
            'cmd.Parameters.Add(New SqlParameter("@UlcerationMultiple", UlcerationMultiple))
            'cmd.Parameters.Add(New SqlParameter("@UlcerationQty", UlcerationQty))
            'cmd.Parameters.Add(New SqlParameter("@UlcerationLength", UlcerationLength))
            'cmd.Parameters.Add(New SqlParameter("@UlcerationClotInBase", UlcerationClotInBase))
            'cmd.Parameters.Add(New SqlParameter("@UlcerationReflux", UlcerationReflux))
            'cmd.Parameters.Add(New SqlParameter("@UlcerationPostSclero", UlcerationPostSclero))
            'cmd.Parameters.Add(New SqlParameter("@UlcerationPostBanding", UlcerationPostBanding))
            'cmd.Parameters.Add(New SqlParameter("@Stricture", Stricture))
            'cmd.Parameters.Add(New SqlParameter("@StrictureCompression", StrictureCompression))
            'cmd.Parameters.Add(New SqlParameter("@StrictureScopeNotPass", StrictureScopeNotPass))
            'cmd.Parameters.Add(New SqlParameter("@StrictureSeverity", StrictureSeverity))
            'cmd.Parameters.Add(New SqlParameter("@StrictureType", StrictureType))
            'cmd.Parameters.Add(New SqlParameter("@StrictureProbably", StrictureProbably))
            'cmd.Parameters.Add(New SqlParameter("@StrictureBenignType", StrictureBenignType))
            'cmd.Parameters.Add(New SqlParameter("@StrictureBeginning", StrictureBeginning))
            'cmd.Parameters.Add(New SqlParameter("@StrictureLength", StrictureLength))
            'cmd.Parameters.Add(New SqlParameter("@StricturePerforation", StricturePerforation))
            cmd.Parameters.Add(New SqlParameter("@Tumour", Tumour))
            cmd.Parameters.Add(New SqlParameter("@Type", TumourType))
            cmd.Parameters.Add(New SqlParameter("@TumourProbably", TumourProbably))
            cmd.Parameters.Add(New SqlParameter("@TumourExophytic", TumourExophytic))
            cmd.Parameters.Add(New SqlParameter("@TumourBenignType", TumourBenignType))
            cmd.Parameters.Add(New SqlParameter("@TumourBenignTypeOther", IIf(TumourBenignTypeOther Is Nothing, "", TumourBenignTypeOther))) 'TumourBenignTypeOther))
            cmd.Parameters.Add(New SqlParameter("@TumourBeginning", TumourBeginning))
            cmd.Parameters.Add(New SqlParameter("@TumourLength", TumourLength))
            cmd.Parameters.Add(New SqlParameter("@TumourLocation", IIf(TumourLocation Is Nothing, "", TumourLocation))) 'edited by mostafiz 3487
            cmd.Parameters.Add(New SqlParameter("@StageT", IIf(StageT Is Nothing, "", StageT)))
            cmd.Parameters.Add(New SqlParameter("@StageN", IIf(StageN Is Nothing, "", StageN)))
            cmd.Parameters.Add(New SqlParameter("@StageM", IIf(StageM Is Nothing, "", StageM)))
            cmd.Parameters.Add(New SqlParameter("@TumourScopeNotPass", TumourScopeNotPass))
            'cmd.Parameters.Add(New SqlParameter("@MiscOther", IIf(MiscOther Is Nothing, "", MiscOther)))
            'cmd.Parameters.Add(New SqlParameter("@InletPatch", InletPatch))
            'cmd.Parameters.Add(New SqlParameter("@InletPatchMultiple", InletPatchMultiple))
            'cmd.Parameters.Add(New SqlParameter("@InletPatchQty", InletPatchQty))

            Dim operatingHospitalId As Integer = CInt(HttpContext.Current.Session("OperatingHospitalID"))
            Dim OBda As New Options
            Dim bIsLAClassification As Boolean = OBda.IsLAClassification(operatingHospitalId)
            cmd.Parameters.Add(New SqlParameter("@IsLAClassification", bIsLAClassification))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))


            connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function
#End Region

#End Region



#Region "ERCP Abnormalities"

#Region "Duct"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveDuctData(ByVal SiteId As Integer,
                                 ByVal Normal As Boolean,
                                 ByVal Dilated As Boolean,
                                 ByVal DilatedLength As Nullable(Of Integer),
                                 ByVal DilatedType As Nullable(Of Integer),
                                 ByVal Stricture As Boolean,
                                 ByVal StrictureLen As Nullable(Of Decimal),
                                 ByVal UpstreamDilatation As Boolean,
                                 ByVal CompleteBlock As Boolean,
                                 ByVal Smooth As Boolean,
                                 ByVal Irregular As Boolean,
                                 ByVal Shouldered As Boolean,
                                 ByVal Tortuous As Boolean,
                                 ByVal StrictureType As Nullable(Of Integer),
                                 ByVal StrictureProbably As Boolean,
                                 ByVal Cholangiocarcinoma As Boolean,
                                 ByVal ExternalCompression As Boolean,
                                 ByVal Fistula As Boolean,
                                 ByVal FistulaQty As Nullable(Of Integer),
                                 ByVal Visceral As Boolean,
                                 ByVal Cutaneous As Boolean,
                                 ByVal FistulaComments As String,
                                 ByVal Stones As Boolean,
                                 ByVal StonesMultiple As Boolean,
                                 ByVal StonesQty As Nullable(Of Integer),
                                 ByVal StonesSize As Nullable(Of Decimal),
                                 ByVal Cysts As Boolean,
                                 ByVal CystsMultiple As Boolean,
                                 ByVal CystsQty As Nullable(Of Integer),
                                 ByVal CystsDiameter As Nullable(Of Decimal),
                                 ByVal CystsSimple As Boolean,
                                 ByVal CystsRegular As Boolean,
                                 ByVal CystsIrregular As Boolean,
                                 ByVal CystsLoculated As Boolean,
                                 ByVal CystsCommunicating As Boolean,
                                 ByVal CystsCholedochal As Boolean,
                                 ByVal CystsSuspectedType As Nullable(Of Integer),
                                 ByVal DuctInjury As Boolean,
                                 ByVal StentOcclusion As Boolean,
                                 ByVal GallBladderTumor As Boolean,
                                 ByVal Diverticulum As Boolean,
                                 ByVal AnastomicStricture As Boolean,
                                 ByVal MirizziSyndrome As Boolean,
                                 ByVal SclerosingCholangitis As Boolean,
                                 ByVal CalculousObstruction As Boolean,
                                 ByVal Occlusion As Boolean,
                                 ByVal BiliaryLeak As Boolean,
                                 ByVal PreviousSurgery As Boolean,
                                 ByVal PancreaticTumour As Boolean,
                                 ByVal ProximallyMigratedStent As Boolean,
                                 ByVal IPMN As Boolean,
                                 ByVal Hemobilia As Boolean,
                                 ByVal Cholangiopathy As Boolean,
                                 ByVal Mass As Boolean,
                                 ByVal MassType As Nullable(Of Integer),
                                 ByVal MassProbably As Boolean,
                                 ByVal Other As String) As Integer

        Dim rowsAffected As Integer
        Try

            'Mahfuz Added Mass,MassType,MassProbably on 14 May 2021

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As SqlCommand = New SqlCommand("abnormalities_duct_save", connection)
                cmd.CommandType = CommandType.StoredProcedure

                cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
                cmd.Parameters.Add(New SqlParameter("@Normal", Normal))
                cmd.Parameters.Add(New SqlParameter("@Dilated", Dilated))
                If DilatedLength.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@DilatedLength", DilatedLength))
                Else
                    cmd.Parameters.Add(New SqlParameter("@DilatedLength", SqlTypes.SqlInt32.Null))
                End If
                If DilatedType.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@DilatedType", DilatedType))
                Else
                    cmd.Parameters.Add(New SqlParameter("@DilatedType", SqlTypes.SqlInt32.Null))
                End If
                cmd.Parameters.Add(New SqlParameter("@Stricture", Stricture))
                If StrictureLen.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@StrictureLen", StrictureLen))
                Else
                    cmd.Parameters.Add(New SqlParameter("@StrictureLen", SqlTypes.SqlDecimal.Null))
                End If
                cmd.Parameters.Add(New SqlParameter("@UpstreamDilatation", UpstreamDilatation))
                cmd.Parameters.Add(New SqlParameter("@CompleteBlock", CompleteBlock))
                cmd.Parameters.Add(New SqlParameter("@Smooth", Smooth))
                cmd.Parameters.Add(New SqlParameter("@Irregular", Irregular))
                cmd.Parameters.Add(New SqlParameter("@Shouldered", Shouldered))
                cmd.Parameters.Add(New SqlParameter("@Tortuous", Tortuous))
                If StrictureType.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@StrictureType", StrictureType))
                Else
                    cmd.Parameters.Add(New SqlParameter("@StrictureType", SqlTypes.SqlInt32.Null))
                End If
                cmd.Parameters.Add(New SqlParameter("@StrictureProbably", StrictureProbably))
                cmd.Parameters.Add(New SqlParameter("@Cholangiocarcinoma", Cholangiocarcinoma))
                cmd.Parameters.Add(New SqlParameter("@ExternalCompression", ExternalCompression))
                cmd.Parameters.Add(New SqlParameter("@Fistula", Fistula))
                If FistulaQty.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@FistulaQty", FistulaQty))
                Else
                    cmd.Parameters.Add(New SqlParameter("@FistulaQty", SqlTypes.SqlInt32.Null))
                End If
                cmd.Parameters.Add(New SqlParameter("@Visceral", Visceral))
                cmd.Parameters.Add(New SqlParameter("@Cutaneous", Cutaneous))
                cmd.Parameters.Add(New SqlParameter("@FistulaComments", FistulaComments))
                cmd.Parameters.Add(New SqlParameter("@Stones", Stones))
                cmd.Parameters.Add(New SqlParameter("@StonesMultiple", StonesMultiple))
                If StonesQty.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@StonesQty", StonesQty))
                Else
                    cmd.Parameters.Add(New SqlParameter("@StonesQty", SqlTypes.SqlInt32.Null))
                End If
                If StonesSize.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@StonesSize", StonesSize))
                Else
                    cmd.Parameters.Add(New SqlParameter("@StonesSize", SqlTypes.SqlDecimal.Null))
                End If
                cmd.Parameters.Add(New SqlParameter("@Cysts", Cysts))
                cmd.Parameters.Add(New SqlParameter("@CystsMultiple", CystsMultiple))
                If CystsQty.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@CystsQty", CystsQty))
                Else
                    cmd.Parameters.Add(New SqlParameter("@CystsQty", SqlTypes.SqlInt32.Null))
                End If
                If CystsDiameter.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@CystsDiameter", CystsDiameter))
                Else
                    cmd.Parameters.Add(New SqlParameter("@CystsDiameter", SqlTypes.SqlDecimal.Null))
                End If
                cmd.Parameters.Add(New SqlParameter("@CystsSimple", CystsSimple))
                cmd.Parameters.Add(New SqlParameter("@CystsRegular", CystsRegular))
                cmd.Parameters.Add(New SqlParameter("@CystsIrregular", CystsIrregular))
                cmd.Parameters.Add(New SqlParameter("@CystsLoculated", CystsLoculated))
                cmd.Parameters.Add(New SqlParameter("@CystsCommunicating", CystsCommunicating))
                cmd.Parameters.Add(New SqlParameter("@CystsCholedochal", CystsCholedochal))
                If CystsSuspectedType.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@CystsSuspectedType", CystsSuspectedType))
                Else
                    cmd.Parameters.Add(New SqlParameter("@CystsSuspectedType", SqlTypes.SqlInt32.Null))
                End If
                cmd.Parameters.Add(New SqlParameter("@DuctInjury", DuctInjury))
                cmd.Parameters.Add(New SqlParameter("@StentOcclusion", StentOcclusion))
                cmd.Parameters.Add(New SqlParameter("@GallBladderTumor", GallBladderTumor))
                cmd.Parameters.Add(New SqlParameter("@Diverticulum", Diverticulum))
                cmd.Parameters.Add(New SqlParameter("@AnastomicStricture", AnastomicStricture))
                cmd.Parameters.Add(New SqlParameter("@MirizziSyndrome", MirizziSyndrome))
                cmd.Parameters.Add(New SqlParameter("@SclerosingCholangitis", SclerosingCholangitis))
                cmd.Parameters.Add(New SqlParameter("@CalculousObstruction", CalculousObstruction))
                cmd.Parameters.Add(New SqlParameter("@Occlusion", Occlusion))
                cmd.Parameters.Add(New SqlParameter("@BiliaryLeak", BiliaryLeak))
                cmd.Parameters.Add(New SqlParameter("@PreviousSurgery", PreviousSurgery))
                cmd.Parameters.Add(New SqlParameter("@PancreaticTumour", PancreaticTumour))
                cmd.Parameters.Add(New SqlParameter("@ProximallyMigratedStent", ProximallyMigratedStent))
                cmd.Parameters.Add(New SqlParameter("@IPMN", IPMN))
                cmd.Parameters.Add(New SqlParameter("@Hemobilia", Hemobilia))
                cmd.Parameters.Add(New SqlParameter("@Cholangiopathy", Cholangiopathy))
                'Mahfuz added on 14 May 2021
                cmd.Parameters.Add(New SqlParameter("@Mass", Mass))
                If MassType.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@MassType", MassType))
                Else
                    cmd.Parameters.Add(New SqlParameter("@MassType", 0)) 'Passing default value as 0
                End If

                cmd.Parameters.Add(New SqlParameter("@MassProbably", MassProbably))
                cmd.Parameters.Add(New SqlParameter("@Other", Other))

                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

                connection.Open()
                cmd.ExecuteNonQuery()
            End Using

        Catch ex As Exception
            Throw ex
        End Try
        Return rowsAffected
    End Function
#End Region

#Region "Parenchyma"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveParenchymaData(ByVal SiteId As Integer,
                                       ByVal Normal As Boolean,
                                       ByVal Irregular As Boolean,
                                       ByVal Dilated As Boolean,
                                       ByVal SmallLakes As Boolean,
                                       ByVal Strictures As Boolean,
                                       ByVal Mass As Boolean,
                                       ByVal MassType As Nullable(Of Integer),
                                       ByVal MassProbably As Boolean,
                                       ByVal SpideryDuctules As Boolean,
                                       ByVal SpiderySuspection As Nullable(Of Integer),
                                       ByVal MultiStrictures As Boolean,
                                       ByVal MultiStricturesSuspection As Nullable(Of Integer),
                                       ByVal Cysts As Boolean,
                                        ByVal CystsMultiple As Boolean,
                                        ByVal CystsQty As Nullable(Of Integer),
                                        ByVal CystsDiameter As Nullable(Of Decimal),
                                        ByVal CystsSimple As Boolean,
                                        ByVal CystsRegular As Boolean,
                                        ByVal CystsIrregular As Boolean,
                                        ByVal CystsLoculated As Boolean,
                                        ByVal CystsCommunicating As Boolean,
                                        ByVal CystsCholedochal As Boolean,
                                        ByVal CystsSuspectedType As Nullable(Of Integer),
                                       ByVal Annulare As Boolean,
                                       ByVal Pancreatitis As Boolean,
                                       ByVal PancreatitisType As Integer,
                                       ByVal Occlusion As Boolean,
                                       ByVal BiliaryLeak As Boolean,
                                       ByVal PreviousSurgery As Boolean,
                                       ByVal Other As String) As Integer

        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("abnormalities_parenchyma_save", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
            cmd.Parameters.Add(New SqlParameter("@Normal", Normal))
            cmd.Parameters.Add(New SqlParameter("@Irregular", Irregular))
            cmd.Parameters.Add(New SqlParameter("@Dilated", Dilated))
            cmd.Parameters.Add(New SqlParameter("@SmallLakes", SmallLakes))
            cmd.Parameters.Add(New SqlParameter("@Strictures", Strictures))
            cmd.Parameters.Add(New SqlParameter("@Mass", Mass))
            If MassType.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@MassType", MassType))
            Else
                cmd.Parameters.Add(New SqlParameter("@MassType", SqlTypes.SqlInt32.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@MassProbably", MassProbably))
            cmd.Parameters.Add(New SqlParameter("@SpideryDuctules", SpideryDuctules))
            If SpiderySuspection.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@SpiderySuspection", SpiderySuspection))
            Else
                cmd.Parameters.Add(New SqlParameter("@SpiderySuspection", SqlTypes.SqlInt32.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@MultiStrictures", MultiStrictures))
            If MultiStricturesSuspection.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@MultiStricturesSuspection", MultiStricturesSuspection))
            Else
                cmd.Parameters.Add(New SqlParameter("@MultiStricturesSuspection", SqlTypes.SqlInt32.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@Annulare", Annulare))
            cmd.Parameters.Add(New SqlParameter("@Pancreatitis", Pancreatitis))
            cmd.Parameters.Add(New SqlParameter("@PancreatitisType", PancreatitisType))
            cmd.Parameters.Add(New SqlParameter("@Other", Other))

            cmd.Parameters.Add(New SqlParameter("@Occlusion", Occlusion))
            cmd.Parameters.Add(New SqlParameter("@BiliaryLeak", BiliaryLeak))
            cmd.Parameters.Add(New SqlParameter("@PreviousSurgery", PreviousSurgery))
            cmd.Parameters.Add(New SqlParameter("@Cysts", Cysts))
            cmd.Parameters.Add(New SqlParameter("@CystsMultiple", CystsMultiple))

            If CystsQty.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@CystsQty", CystsQty))
            Else
                cmd.Parameters.Add(New SqlParameter("@CystsQty", 0))
            End If
            cmd.Parameters.Add(New SqlParameter("@CystsDiameter", CystsDiameter))
            cmd.Parameters.Add(New SqlParameter("@CystsSimple", CystsSimple))
            cmd.Parameters.Add(New SqlParameter("@CystsRegular", CystsRegular))
            cmd.Parameters.Add(New SqlParameter("@CystsIrregular", CystsIrregular))
            cmd.Parameters.Add(New SqlParameter("@CystsLoculated", CystsLoculated))
            cmd.Parameters.Add(New SqlParameter("@CystsCommunicating", CystsCommunicating))
            cmd.Parameters.Add(New SqlParameter("@CystsCholedochal", CystsCholedochal))
            cmd.Parameters.Add(New SqlParameter("@CystsSuspectedType", CystsSuspectedType))

            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

            connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function
#End Region

#Region "Appearance"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveAppearanceData(ByVal siteId As Integer,
                                       ByVal normal As Boolean,
                                       ByVal bleeding As Boolean,
                                       ByVal suprapapillary As Boolean,
                                       ByVal impactedStone As Boolean,
                                       ByVal patulous As Boolean,
                                       ByVal inflamed As Boolean,
                                       ByVal oedematous As Boolean,
                                       ByVal pusExuding As Boolean,
                                       ByVal reddened As Boolean,
                                       ByVal tumour As Boolean,
                                       ByVal occlusion As Boolean,
                                       ByVal biliaryLeak As Boolean,
                                       ByVal previousSurgery As Boolean,
                                       ByVal PapillaryStenosis As Boolean,
                                       ByVal other As Boolean,
                                       ByVal otherText As String) As Integer

        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("abnormalities_appearance_save", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
            cmd.Parameters.Add(New SqlParameter("@Normal", normal))
            cmd.Parameters.Add(New SqlParameter("@Bleeding", bleeding))
            cmd.Parameters.Add(New SqlParameter("@Suprapapillary", suprapapillary))
            cmd.Parameters.Add(New SqlParameter("@ImpactedStone", impactedStone))
            cmd.Parameters.Add(New SqlParameter("@Patulous", patulous))
            cmd.Parameters.Add(New SqlParameter("@Inflamed", inflamed))
            cmd.Parameters.Add(New SqlParameter("@Oedematous", oedematous))
            cmd.Parameters.Add(New SqlParameter("@PusExuding", pusExuding))
            cmd.Parameters.Add(New SqlParameter("@Reddened", reddened))
            cmd.Parameters.Add(New SqlParameter("@Tumour", tumour))
            cmd.Parameters.Add(New SqlParameter("@Occlusion", occlusion))
            cmd.Parameters.Add(New SqlParameter("@BiliaryLeak", biliaryLeak))
            cmd.Parameters.Add(New SqlParameter("@PreviousSurgery", previousSurgery))
            cmd.Parameters.Add(New SqlParameter("@PapillaryStenosis", PapillaryStenosis))
            cmd.Parameters.Add(New SqlParameter("@Other", other))
            cmd.Parameters.Add(New SqlParameter("@OtherText", otherText))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

            connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function
#End Region

#Region "Diverticulum"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveDiverticulumData(ByVal SiteId As Integer,
                                         ByVal Normal As Boolean,
                                         ByVal Quantity As Nullable(Of Integer),
                                         ByVal SizeOfLargest As Nullable(Of Decimal),
                                         ByVal Proximity As Integer,
                                         ByVal Occlusion As Boolean,
                                         ByVal BiliaryLeak As Boolean,
                                         ByVal PreviousSurgery As Boolean,
                                         ByVal Other As String) As Integer

        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("abnormalities_diverticulum_ercp_save", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
            cmd.Parameters.Add(New SqlParameter("@Normal", Normal))
            If Quantity.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@Quantity", Quantity))
            Else
                cmd.Parameters.Add(New SqlParameter("@Quantity", SqlTypes.SqlInt32.Null))
            End If
            If SizeOfLargest.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@SizeOfLargest", SizeOfLargest))
            Else
                cmd.Parameters.Add(New SqlParameter("@SizeOfLargest", SqlTypes.SqlDecimal.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@Proximity", Proximity))
            cmd.Parameters.Add(New SqlParameter("@Occlusion", Occlusion))
            cmd.Parameters.Add(New SqlParameter("@BiliaryLeak", BiliaryLeak))
            cmd.Parameters.Add(New SqlParameter("@PreviousSurgery", PreviousSurgery))
            cmd.Parameters.Add(New SqlParameter("@Other", Other))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

            connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function
#End Region

#Region "Tumour"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveTumourData(ByVal SiteId As Integer,
                                    ByVal None As Boolean,
                                    ByVal Firm As Boolean,
                                    ByVal Friable As Boolean,
                                    ByVal Ulcerated As Boolean,
                                    ByVal Villous As Boolean,
                                    ByVal Polypoid As Boolean,
                                    ByVal SubMucosal As Boolean,
                                    ByVal Size As Nullable(Of Decimal),
                                    ByVal Occlusion As Boolean,
                                    ByVal BiliaryLeak As Boolean,
                                    ByVal PreviousSurgery As Boolean,
                                    ByVal IPMT As Boolean,
                                    ByVal Other As String) As Integer

        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("abnormalities_tumour_ercp_save", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
            cmd.Parameters.Add(New SqlParameter("@None", None))
            cmd.Parameters.Add(New SqlParameter("@Firm", Firm))
            cmd.Parameters.Add(New SqlParameter("@Friable", Friable))
            cmd.Parameters.Add(New SqlParameter("@Ulcerated", Ulcerated))
            cmd.Parameters.Add(New SqlParameter("@Villous", Villous))
            cmd.Parameters.Add(New SqlParameter("@Polypoid", Polypoid))
            cmd.Parameters.Add(New SqlParameter("@SubMucosal", SubMucosal))
            If Size.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@Size", Size))
            Else
                cmd.Parameters.Add(New SqlParameter("@Size", SqlTypes.SqlDecimal.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@Other", Other))
            cmd.Parameters.Add(New SqlParameter("@Occlusion", Occlusion))
            cmd.Parameters.Add(New SqlParameter("@BiliaryLeak", BiliaryLeak))
            cmd.Parameters.Add(New SqlParameter("@PreviousSurgery", PreviousSurgery))
            cmd.Parameters.Add(New SqlParameter("@IPMT", IPMT))

            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

            connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function
#End Region

#End Region


#Region "BRT Abnormalities"

    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetBRTAbnosData(siteId As Integer) As DataTable
    '    Dim dsResult As New DataSet

    '    Using connection As New SqlConnection(DataAccess.ConnectionStr)
    '        Dim cmd As New SqlCommand("abnormalities_brt_descriptions_select", connection)
    '        cmd.CommandType = CommandType.StoredProcedure
    '        cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
    '        Dim adapter = New SqlDataAdapter(cmd)

    '        connection.Open()
    '        adapter.Fill(dsResult)
    '    End Using

    '    If dsResult.Tables.Count > 0 Then
    '        Return dsResult.Tables(0)
    '    End If
    '    Return Nothing
    'End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveBRTAbnosData(ByVal SiteId As Integer,
                                        ByVal Normal As Boolean,
                                        ByVal Carinal As Integer?,
                                        ByVal Vocal As Integer?,
                                        ByVal Compression As Boolean?,
                                        ByVal CompressionGeneral As Boolean?,
                                        ByVal CompressionFromLeft As Boolean?,
                                        ByVal CompressionFromRight As Boolean?,
                                        ByVal CompressionFromAnterior As Boolean?,
                                        ByVal CompressionFromPosterior As Boolean?,
                                        ByVal Stenosis As Integer?,
                                        ByVal Obstruction As Integer?,
                                        ByVal Mucosal As Boolean?,
                                        ByVal MucosalOedema As Boolean?,
                                        ByVal MucosalErythema As Boolean?,
                                        ByVal MucosalPits As Boolean?,
                                        ByVal MucosalAnthracosis As Boolean?,
                                        ByVal MucosalInfiltration As Boolean?,
                                        ByVal MucosalIrregularity As Integer?,
                                        ByVal ExcessiveSecretions As Integer?,
                                        ByVal Bleeding As Integer?) As Integer

        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("abnormalities_brt_descriptions_save", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
            cmd.Parameters.Add(New SqlParameter("@Normal", Normal))
            If Carinal.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@Carinal", Carinal))
            Else
                cmd.Parameters.Add(New SqlParameter("@Carinal", SqlTypes.SqlDecimal.Null))
            End If

            If Vocal.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@Vocal", Vocal))
            Else
                cmd.Parameters.Add(New SqlParameter("@Vocal", SqlTypes.SqlDecimal.Null))
            End If
            If Compression.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@Compression", Compression))
            Else
                cmd.Parameters.Add(New SqlParameter("@Compression", SqlTypes.SqlDecimal.Null))
            End If
            If CompressionGeneral.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@CompressionGeneral", CompressionGeneral))
            Else
                cmd.Parameters.Add(New SqlParameter("@CompressionGeneral", SqlTypes.SqlDecimal.Null))
            End If
            If CompressionFromLeft.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@CompressionFromLeft", CompressionFromLeft))
            Else
                cmd.Parameters.Add(New SqlParameter("@CompressionFromLeft", SqlTypes.SqlDecimal.Null))
            End If
            If CompressionFromRight.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@CompressionFromRight", CompressionFromRight))
            Else
                cmd.Parameters.Add(New SqlParameter("@CompressionFromRight", SqlTypes.SqlDecimal.Null))
            End If
            If CompressionFromAnterior.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@CompressionFromAnterior", CompressionFromAnterior))
            Else
                cmd.Parameters.Add(New SqlParameter("@CompressionFromAnterior", SqlTypes.SqlDecimal.Null))
            End If
            If CompressionFromPosterior.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@CompressionFromPosterior", CompressionFromPosterior))
            Else
                cmd.Parameters.Add(New SqlParameter("@CompressionFromPosterior", SqlTypes.SqlDecimal.Null))
            End If
            If Stenosis.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@Stenosis", Stenosis))
            Else
                cmd.Parameters.Add(New SqlParameter("@Stenosis", SqlTypes.SqlDecimal.Null))
            End If
            If Obstruction.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@Obstruction", Obstruction))
            Else
                cmd.Parameters.Add(New SqlParameter("@Obstruction", SqlTypes.SqlDecimal.Null))
            End If
            If Mucosal.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@Mucosal", Mucosal))
            Else
                cmd.Parameters.Add(New SqlParameter("@Mucosal", SqlTypes.SqlDecimal.Null))
            End If
            If MucosalOedema.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@MucosalOedema", MucosalOedema))
            Else
                cmd.Parameters.Add(New SqlParameter("@MucosalOedema", SqlTypes.SqlDecimal.Null))
            End If
            If MucosalErythema.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@MucosalErythema", MucosalErythema))
            Else
                cmd.Parameters.Add(New SqlParameter("@MucosalErythema", SqlTypes.SqlDecimal.Null))
            End If
            If MucosalPits.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@MucosalPits", MucosalPits))
            Else
                cmd.Parameters.Add(New SqlParameter("@MucosalPits", SqlTypes.SqlDecimal.Null))
            End If
            If MucosalAnthracosis.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@MucosalAnthracosis", MucosalAnthracosis))
            Else
                cmd.Parameters.Add(New SqlParameter("@MucosalAnthracosis", SqlTypes.SqlDecimal.Null))
            End If
            If MucosalInfiltration.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@MucosalInfiltration", MucosalInfiltration))
            Else
                cmd.Parameters.Add(New SqlParameter("@MucosalInfiltration", SqlTypes.SqlDecimal.Null))
            End If
            If MucosalIrregularity.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@MucosalIrregularity", MucosalIrregularity))
            Else
                cmd.Parameters.Add(New SqlParameter("@MucosalIrregularity", SqlTypes.SqlDecimal.Null))
            End If
            If ExcessiveSecretions.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@ExcessiveSecretions", ExcessiveSecretions))
            Else
                cmd.Parameters.Add(New SqlParameter("@ExcessiveSecretions", SqlTypes.SqlDecimal.Null))
            End If
            If Bleeding.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@Bleeding", Bleeding))
            Else
                cmd.Parameters.Add(New SqlParameter("@Bleeding", SqlTypes.SqlDecimal.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))
            connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveEbusAbnosData(ByVal EBUSAbnoDescId As Integer,
                                     ByVal siteId As Integer,
                                        ByVal normal As Boolean,
                                        ByVal size As Double?,
                                        ByVal sizeNum As Integer?,
                                        ByVal shape As Integer?,
                                        ByVal margin As Integer?,
                                        ByVal echoGenecity As Integer?,
                                        ByVal cHS As Integer?,
                                        ByVal cNS As Integer?,
                                        ByVal vascular As Integer?,
                                        ByVal bxType As Integer?,
                                        ByVal noBxTaken As Integer?,
                                        ByVal bxNeedleType As Integer?,
                                        ByVal bxNeedleSize As Integer?,
                                        ByVal bxNeedleSizeUnits As Integer?) As Integer

        Try
            Dim rowsAffected As Integer

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As SqlCommand = New SqlCommand("abnormalities_ebus_descriptions_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@EBUSAbnoDescId", EBUSAbnoDescId))
                cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
                cmd.Parameters.Add(New SqlParameter("@Normal", normal))

                If size.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@Size", size))
                Else
                    cmd.Parameters.Add(New SqlParameter("@Size", 0))
                End If

                If sizeNum.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@SizeNum", sizeNum))
                Else
                    cmd.Parameters.Add(New SqlParameter("@SizeNum", 0))
                End If

                If shape.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@Shape", shape))
                Else
                    cmd.Parameters.Add(New SqlParameter("@Shape", 0))
                End If

                If margin.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@Margin", margin))
                Else
                    cmd.Parameters.Add(New SqlParameter("@Margin", 0))
                End If

                If echoGenecity.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@echoGenecity", echoGenecity))
                Else
                    cmd.Parameters.Add(New SqlParameter("@echoGenecity", 0))
                End If

                If cHS.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@CHS", cHS))
                Else
                    cmd.Parameters.Add(New SqlParameter("@CHS", 0))
                End If

                If cNS.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@CNS", cNS))
                Else
                    cmd.Parameters.Add(New SqlParameter("@CNS", 0))
                End If

                If vascular.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@Vascular", vascular))
                Else
                    cmd.Parameters.Add(New SqlParameter("@Vascular", 0))
                End If

                If bxType.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@BxType", bxType))
                Else
                    cmd.Parameters.Add(New SqlParameter("@BxType", 0))
                End If

                If noBxTaken.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@NoBxTaken", noBxTaken))
                Else
                    cmd.Parameters.Add(New SqlParameter("@NoBxTaken", 0))
                End If

                If bxNeedleType.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@BxNeedleType", bxNeedleType))
                Else
                    cmd.Parameters.Add(New SqlParameter("@BxNeedleType", -1))
                End If

                If bxNeedleSize.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@BxNeedleSize", bxNeedleSize))
                Else
                    cmd.Parameters.Add(New SqlParameter("@BxNeedleSize", 0))
                End If

                If bxNeedleSizeUnits.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@BxNeedleSizeUnits", bxNeedleSizeUnits))
                Else
                    cmd.Parameters.Add(New SqlParameter("@BxNeedleSizeUnits", -1))
                End If

                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))
                connection.Open()
                rowsAffected = CInt(cmd.ExecuteNonQuery())
            End Using

            Return rowsAffected

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error in Function: Abnormalities.SaveEbusAbnosData...", ex)
            Return False
        End Try

    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function InsertEbusAbnosData(ByVal EBUSAbnoDescId As Integer,
                                     ByVal siteId As Integer,
                                        ByVal normal As Boolean,
                                        ByVal size As Double?,
                                        ByVal sizeNum As Integer?,
                                        ByVal shape As Integer?,
                                        ByVal margin As Integer?,
                                        ByVal echoGenecity As Integer?,
                                        ByVal cHS As Integer?,
                                        ByVal cNS As Integer?,
                                        ByVal vascular As Integer?,
                                        ByVal bxType As Integer?,
                                        ByVal noBxTaken As Integer?,
                                        ByVal bxNeedleType As Integer?,
                                        ByVal bxNeedleSize As Integer?,
                                        ByVal bxNeedleSizeUnits As Integer?) As Integer

        Try
            Dim rowsAffected As Integer

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As SqlCommand = New SqlCommand("abnormalities_ebus_descriptions_insert", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@EBUSAbnoDescId", EBUSAbnoDescId))
                cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
                cmd.Parameters.Add(New SqlParameter("@Normal", normal))

                If size.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@Size", size))
                Else
                    cmd.Parameters.Add(New SqlParameter("@Size", 0))
                End If

                If sizeNum.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@SizeNum", sizeNum))
                Else
                    cmd.Parameters.Add(New SqlParameter("@SizeNum", 0))
                End If

                If shape.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@Shape", shape))
                Else
                    cmd.Parameters.Add(New SqlParameter("@Shape", 0))
                End If

                If margin.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@Margin", margin))
                Else
                    cmd.Parameters.Add(New SqlParameter("@Margin", 0))
                End If

                If echoGenecity.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@echoGenecity", echoGenecity))
                Else
                    cmd.Parameters.Add(New SqlParameter("@echoGenecity", 0))
                End If

                If cHS.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@CHS", cHS))
                Else
                    cmd.Parameters.Add(New SqlParameter("@CHS", 0))
                End If

                If cNS.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@CNS", cNS))
                Else
                    cmd.Parameters.Add(New SqlParameter("@CNS", 0))
                End If

                If vascular.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@Vascular", vascular))
                Else
                    cmd.Parameters.Add(New SqlParameter("@Vascular", 0))
                End If

                If bxType.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@BxType", bxType))
                Else
                    cmd.Parameters.Add(New SqlParameter("@BxType", 0))
                End If

                If noBxTaken.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@NoBxTaken", noBxTaken))
                Else
                    cmd.Parameters.Add(New SqlParameter("@NoBxTaken", 0))
                End If

                If bxNeedleType.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@BxNeedleType", bxNeedleType))
                Else
                    cmd.Parameters.Add(New SqlParameter("@BxNeedleType", -1))
                End If

                If bxNeedleSize.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@BxNeedleSize", bxNeedleSize))
                Else
                    cmd.Parameters.Add(New SqlParameter("@BxNeedleSize", 0))
                End If

                If bxNeedleSizeUnits.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@BxNeedleSizeUnits", bxNeedleSizeUnits))
                Else
                    cmd.Parameters.Add(New SqlParameter("@BxNeedleSizeUnits", -1))
                End If

                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))
                Dim outputParameter As New SqlParameter("@PrimaryKey", SqlDbType.Int) With         'set -1 instead of 50 if need nvarchar(max)
                        {
                            .Direction = ParameterDirection.Output
                        }
                cmd.Parameters.Add(outputParameter)

                connection.Open()
                rowsAffected = CInt(cmd.ExecuteNonQuery())
                EBUSAbnoDescId = cmd.Parameters("@PrimaryKey").Value
            End Using

            Return EBUSAbnoDescId

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error in Function: Abnormalities.SaveEbusAbnosData...", ex)
            Return False
        End Try

    End Function



    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveBronchsAbnosBleedingData(ByVal SiteId As Integer,
                                        ByVal Normal As Boolean,
                                        ByVal Bleeding As Integer) As Integer
        Dim rowsAffected As Integer
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("abnormalities_brt_descriptions_save", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
            cmd.Parameters.Add(New SqlParameter("@Normal", Normal))
            cmd.Parameters.Add(New SqlParameter("@Bleeding", Bleeding))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))
            connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function

#End Region

#Region "Cystoscopy"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveCystoscopyBladderAbnosData(ByVal SiteId As Integer,
                                      ByVal Normal As Boolean,
                                      ByVal Tumor As Boolean?,
                                      ByVal TumorQuantity As Double?,
                                      ByVal TumorSizeofLargest As Double?,
                                      ByVal TumorMultiple As Boolean?,
                                      ByVal TumorFlat As Boolean?,
                                      ByVal TumorFungating As Boolean?,
                                      ByVal TumorPapilary As Boolean?,
                                      ByVal TumorSolid As Boolean?,
                                      ByVal CystitisCystica As Boolean?,
                                      ByVal Diverticulum As Boolean?,
                                      ByVal Fistula As Boolean?,
                                      ByVal RadiationCystitis As Boolean?,
                                      ByVal RedPatch As Boolean?,
                                      ByVal Stones As Boolean?,
                                      ByVal AbnormalPosition As Boolean?,
                                      ByVal CoveredWithTumour As Boolean?,
                                      ByVal ExtraUretericOrifice As Boolean?,
                                      ByVal Ureterocoele As Boolean?
                                      ) As Integer

        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("abnormalities_cystoscopy_bladder_save", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
            cmd.Parameters.Add(New SqlParameter("@Normal", Normal))
            If Tumor.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@Tumor", Tumor))
            Else
                cmd.Parameters.Add(New SqlParameter("@Tumor", SqlTypes.SqlDecimal.Null))
            End If

            If TumorQuantity.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@TumorQuantity", TumorQuantity))
            Else
                cmd.Parameters.Add(New SqlParameter("@TumorQuantity", 0))
            End If

            If TumorSizeofLargest.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@TumorSizeofLargest", TumorSizeofLargest))
            Else
                cmd.Parameters.Add(New SqlParameter("@TumorSizeofLargest", 0))
            End If
            If TumorMultiple.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@TumorMultiple", TumorMultiple))
            Else
                cmd.Parameters.Add(New SqlParameter("@TumorMultiple", SqlTypes.SqlDecimal.Null))
            End If
            If TumorFlat.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@TumorFlat", TumorFlat))
            Else
                cmd.Parameters.Add(New SqlParameter("@TumorFlat", SqlTypes.SqlDecimal.Null))
            End If
            If TumorFungating.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@TumorFungating", TumorFungating))
            Else
                cmd.Parameters.Add(New SqlParameter("@TumorFungating", SqlTypes.SqlDecimal.Null))
            End If
            If TumorPapilary.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@TumorPapilary", TumorPapilary))
            Else
                cmd.Parameters.Add(New SqlParameter("@TumorPapilary", SqlTypes.SqlDecimal.Null))
            End If
            If TumorSolid.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@TumorSolid", TumorSolid))
            Else
                cmd.Parameters.Add(New SqlParameter("@TumorSolid", SqlTypes.SqlDecimal.Null))
            End If
            If CystitisCystica.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@CystitisCystica", CystitisCystica))
            Else
                cmd.Parameters.Add(New SqlParameter("@CystitisCystica", SqlTypes.SqlDecimal.Null))
            End If
            If Diverticulum.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@Diverticulum", Diverticulum))
            Else
                cmd.Parameters.Add(New SqlParameter("@Diverticulum", SqlTypes.SqlDecimal.Null))
            End If
            If Fistula.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@Fistula", Fistula))
            Else
                cmd.Parameters.Add(New SqlParameter("@Fistula", SqlTypes.SqlDecimal.Null))
            End If
            If RadiationCystitis.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@RadiationCystitis", RadiationCystitis))
            Else
                cmd.Parameters.Add(New SqlParameter("@RadiationCystitis", SqlTypes.SqlDecimal.Null))
            End If
            If RedPatch.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@RedPatch", RedPatch))
            Else
                cmd.Parameters.Add(New SqlParameter("@RedPatch", SqlTypes.SqlDecimal.Null))
            End If
            If Stones.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@Stones", Stones))
            Else
                cmd.Parameters.Add(New SqlParameter("@Stones", SqlTypes.SqlDecimal.Null))
            End If
            If AbnormalPosition.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@AbnormalPosition", AbnormalPosition))
            Else
                cmd.Parameters.Add(New SqlParameter("@AbnormalPosition", SqlTypes.SqlDecimal.Null))
            End If
            If CoveredWithTumour.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@CoveredWithTumour", CoveredWithTumour))
            Else
                cmd.Parameters.Add(New SqlParameter("@CoveredWithTumour", SqlTypes.SqlDecimal.Null))
            End If
            If CoveredWithTumour.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@ExtraUretericOrifice", ExtraUretericOrifice))
            Else
                cmd.Parameters.Add(New SqlParameter("@ExtraUretericOrifice", SqlTypes.SqlDecimal.Null))
            End If


            If Ureterocoele.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@Ureterocoele", Ureterocoele))
            Else
                cmd.Parameters.Add(New SqlParameter("@Ureterocoele", SqlTypes.SqlDecimal.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))
            connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function

    Public Function SaveCystoscopyProstateAbnosData(ByVal SiteId As Integer,
                                         ByVal Normal As Boolean,
                                         ByVal Irregular As Boolean?,
                                         ByVal Large As Boolean?,
                                         ByVal Obstructive As Boolean?,
                                          ByVal Vascular As Boolean?,
                                         ByVal RedPatch As Boolean?
                                         ) As Integer

        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("abnormalities_cystoscopy_Prostate_save", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
            cmd.Parameters.Add(New SqlParameter("@Normal", Normal))
            cmd.Parameters.Add(New SqlParameter("@Irregular", Irregular))
            cmd.Parameters.Add(New SqlParameter("@Large", Large))
            cmd.Parameters.Add(New SqlParameter("@Obstructive", Obstructive))
            cmd.Parameters.Add(New SqlParameter("@Vascular", Vascular))
            cmd.Parameters.Add(New SqlParameter("@RedPatch", RedPatch))


            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))
            connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function


    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveCystoscopyUrethraAbnosData(ByVal SiteId As Integer,
                                     ByVal Normal As Boolean,
                                     ByVal Tumour As Boolean?,
                                     ByVal Blood As Boolean?,
                                     ByVal PosteriorUrethralValves As Boolean?,
                                     ByVal Stones As Boolean?,
                                     ByVal Stricture As Boolean?,
                                     ByVal Tear As Boolean?,
                                     ByVal Wart As Boolean?,
                                     ByVal Epispadias As Boolean?,
                                     ByVal Hypospadias As Boolean?,
                                     ByVal Small As Boolean?,
                                     ByVal RedPatch As Boolean?
                                     ) As Integer

        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("abnormalities_cystoscopy_urethra_save", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
            cmd.Parameters.Add(New SqlParameter("@Normal", Normal))
            cmd.Parameters.Add(New SqlParameter("@Tumour", Tumour))
            cmd.Parameters.Add(New SqlParameter("@Blood", Blood))
            cmd.Parameters.Add(New SqlParameter("@PosteriorUrethralValves", PosteriorUrethralValves))
            cmd.Parameters.Add(New SqlParameter("@Stones", Stones))
            cmd.Parameters.Add(New SqlParameter("@Stricture", Stricture))
            cmd.Parameters.Add(New SqlParameter("@Tear", Tear))
            cmd.Parameters.Add(New SqlParameter("@Wart", Wart))
            cmd.Parameters.Add(New SqlParameter("@Epispadias", Epispadias))
            cmd.Parameters.Add(New SqlParameter("@Hypospadias", Hypospadias))
            cmd.Parameters.Add(New SqlParameter("@Small", Small))

            cmd.Parameters.Add(New SqlParameter("@RedPatch", RedPatch))

            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))
            connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function
#End Region

End Class
