Imports Microsoft.VisualBasic
Imports UnisoftERS.Constants
Imports System.Data.SqlClient
Imports ERS.Data
Imports System.Web.SessionState.HttpSessionState

Public Class Therapeutics

    Public Function GetInstrumentUsed(SiteID As Integer) As String
        Dim InstrumentUsed As String = "Gastrostomy insertion (PEG)"
        Dim dsResult As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("SELECT i.[JejunostomyInsertion],i.[GastrostomyInsertion],i.[NasoDuodenalTube] FROM [ERS_UpperGIIndications] i LEFT JOIN [ERS_Sites] s ON i.ProcedureId = s.ProcedureId WHERE s.SiteId = @SiteID", connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@SiteID", SiteID))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsResult)
        End Using
        If dsResult.Tables(0).Rows.Count > 0 Then
            Dim d As DataRow = dsResult.Tables(0).Rows(0)
            If CBool(d("GastrostomyInsertion")) Then
                InstrumentUsed = "Gastrostomy insertion (PEG)"
            ElseIf CBool(d("NasoDuodenalTube")) Then
                InstrumentUsed = "Nasojejunal tube (NJT)"
            ElseIf CBool(d("JejunostomyInsertion")) Then
                InstrumentUsed = "Jejunostomy insertion (PEJ)"
            End If
        End If
        Return InstrumentUsed
    End Function

    Public Function GetNPSAalert(ProcedureID As Integer) As String
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("SELECT PP_NPSAalert FROM ERS_ProceduresReporting WHERE ProcedureID = @ProcedureID", connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@ProcedureID", ProcedureID))
            connection.Open()
            Dim rObj As Object = cmd.ExecuteScalar()
            If IsDBNull(rObj) Then
                Return ""
            Else
                Return CStr(rObj)
            End If
        End Using
    End Function
    Public Function SaveNPSAalert(ProcedureID As Integer, PP_NPSAalert As String) As Integer
        Dim rowsAffected As Integer
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("UPDATE ERS_ProceduresReporting SET PP_NPSAalert = @PP_NPSAalert WHERE ProcedureID = @ProcedureID;Exec ProceduresReporting_Updated @ProcedureId;", connection)
            cmd.CommandType = CommandType.Text

            cmd.Parameters.Add(New SqlParameter("@ProcedureID", ProcedureID))
            cmd.Parameters.Add(New SqlParameter("@PP_NPSAalert", PP_NPSAalert))

            cmd.Connection.Open()
            rowsAffected = cmd.ExecuteNonQuery()
        End Using
        Return rowsAffected
    End Function

    Private Function chkNull(value As Object) As Object
        If value Is Nothing Then
            Return DBNull.Value
        Else
            Return value
        End If
    End Function

    Public Function GetTherapeuticRecords(ByVal siteId As Integer) As ERS.Data.EndoscopistSearch_Result
        Dim result As IQueryable(Of ERS.Data.EndoscopistSearch_Result)
        Try
            Using db As New ERS.Data.GastroDbEntities
                '### First get the Details about the Endoscopist! Both 1 and 2 wherever applicable!
                result = db.EndoscopistSelectByProcedureSite(0, siteId)
                Return result.FirstOrDefault()
            End Using


        Catch ex As Exception

            Return Nothing
        End Try

    End Function

    Public Function TherapeuticRecord_UGI_FindBySite(ByVal SiteId As Integer) As ERS.Data.ERS_UpperGITherapeutics
        Using db As New ERS.Data.GastroDbEntities
            'Return db.ERS_UpperGITherapeutics.Where(Function(t) t.SiteId = SiteId And t.CarriedOutRole = EndRole).FirstOrDefault()
            Return db.ERS_UpperGITherapeutics.Where(Function(t) t.SiteId = SiteId).FirstOrDefault()
        End Using
    End Function

    Public Function TherapeuticRecord_ERCP_FindBySite(ByVal SiteId As Integer) As ERS.Data.ERS_ERCPTherapeutics
        Using db As New ERS.Data.GastroDbEntities
            Return db.ERS_ERCPTherapeutics.Where(Function(t) t.SiteId = SiteId).FirstOrDefault()
        End Using
    End Function

    Public Enum SaveAs
        InsertNew
        Update
    End Enum

    ''' <summary>
    ''' This will save the OGD Therapeutic Records
    ''' </summary>
    ''' <param name="ercp">ERCP Record Object</param>
    ''' <param name="save">INSERT or UPDATE</param>
    ''' <remarks></remarks>
    Public Sub TherapeuticRecord_Save(ByVal ercp As ERS_ERCPTherapeutics, ByVal save As SaveAs, ByVal procedureId As Integer)
        'ByVal hasNoneChecked As Boolean,       
        Dim da As New DataAccess

        If ercp.MarkingType.HasValue AndAlso ercp.MarkingType = -99 Then
            Dim newId = da.InsertListItem("Abno marking", ercp.MarkingTypeNewItemText)
            If newId > 0 Then ercp.MarkingType = newId
        End If

        If ercp.InjectionType.HasValue AndAlso ercp.InjectionType = -99 Then
            Dim newId = da.InsertListItem("Agent Upper GI", ercp.InjectionTypeNewItemText)
            If newId > 0 Then ercp.InjectionType = newId
        End If

        'If ercp.GastrostomyInsertionType.HasValue AndAlso ercp.GastrostomyInsertionType = -99 Then
        '    Dim newId = da.InsertListItem("Gastrostomy PEG type", ercp.GastrostomyInsertionTypeNewItemText)
        '    If newId > 0 Then ercp.GastrostomyInsertionType = newId
        'End If

        If ercp.EMRFluid.HasValue AndAlso ercp.EMRFluid = -99 Then
            Dim newId = da.InsertListItem("Therapeutic EMR Fluid", ercp.EMRFluidNewItemText)
            If newId > 0 Then ercp.EMRFluid = newId
        End If

        If ercp.StentRemovalTechnique.HasValue AndAlso ercp.StentRemovalTechnique = -99 Then
            Dim newId = da.InsertListItem("Therapeutic Stent Removal Technique", ercp.StentRemovalTechniqueNewItemText)
            If newId > 0 Then ercp.StentRemovalTechnique = newId
        End If

        If ercp.Homeostasis AndAlso ercp.HomeostasisType = -99 Then
            Dim newId = da.InsertListItem("Homeostasis", ercp.HomeostasisTypeNewItemText)
            If newId > 0 Then ercp.HomeostasisType = newId
        End If

        Using db As New ERS.Data.GastroDbEntities

            If save = SaveAs.InsertNew Then
                ercp.WhoCreatedId = CInt(HttpContext.Current.Session("PKUserID"))
                ercp.WhenCreated = Now
                Dim result = db.ERS_ERCPTherapeutics.Add(ercp)
            ElseIf save = SaveAs.Update Then
                ercp.WhoUpdatedId = CInt(HttpContext.Current.Session("PKUserID"))
                ercp.WhenUpdated = Now
                db.ERS_ERCPTherapeutics.Attach(ercp)
                db.Entry(ercp).State = Entity.EntityState.Modified
            End If

            '### Now time to play with Record Counter. Its Duplicating for ERCP and UGI. Can't share.. As they need to be in the Same TRANSACTION COMMIT
            Dim ersRecord As ERS_RecordCount
            ersRecord = db.ERS_RecordCount.Where(Function(ers) ers.SiteId = ercp.SiteId And ers.Identifier = "Therapeutic Procedures").FirstOrDefault()

            If ersRecord Is Nothing Then
                ersRecord = New ERS_RecordCount

                ersRecord.ProcedureId = procedureId
                ersRecord.SiteId = ercp.SiteId
                ersRecord.Identifier = "Therapeutic Procedures"
                ersRecord.RecordCount = 1

                db.ERS_RecordCount.Add(ersRecord) '### Second INSERT in the TRANSACTION
            End If

            db.SaveChanges() '### Tell the EF to accept the Changes!
            'Added by Nasim (Reason: Drop insert trigger of ERS_ERCPTherapeutics)
            da.Update_ogd_kpi_stricture_perforation(ercp.SiteId)
            da.Update_therapeutics_ercp_summary(ercp.SiteId, ercp.Id)
            da.Update_sites_summary(ercp.SiteId)
        End Using

    End Sub

    ''' <summary>
    ''' This will save the OGD Therapeutic Records
    ''' </summary>
    ''' <param name="UGI">UpperGI Record Object</param>
    ''' <param name="save">INSERT or UPDATE</param>
    ''' <remarks></remarks>
    Public Sub TherapeuticRecord_UGI_Save(ByVal UGI As ERS_UpperGITherapeutics, ByVal save As SaveAs, ByVal procedureId As Integer)
        Dim da As New DataAccess

        '##### 1) Insert the Newly added Lookupvalues in ERS_List table, from the Dropdowns
        If UGI.StentInsertionType.HasValue And UGI.StentInsertionType = -99 Then
            Dim sListDescription As String = ""
            If Right(UGI.StentInsertionTypeNewItemText, 12) = "|Oesophagus|" Then
                sListDescription = "Therapeutic Stent Insertion Types"
                UGI.StentInsertionTypeNewItemText = Left(UGI.StentInsertionTypeNewItemText, Len(UGI.StentInsertionTypeNewItemText) - 12)
            Else
                sListDescription = "Therapeutic Stomach Stent Insertion Types"
            End If
            Dim newId = da.InsertListItem(sListDescription, UGI.StentInsertionTypeNewItemText)
            If newId > 0 Then UGI.StentInsertionType = newId
        End If
        ' ADDED BY MOSTAFIZ ISSUE 2743
        If UGI.BalloonDilationType.HasValue AndAlso UGI.BalloonDilationType = -99 Then
            Dim newId = da.InsertListItem("Therapeutic Balloon Dilation Types", UGI.BalloonDilationTypeNewItemText)
            If newId > 0 Then UGI.BalloonDilationType = newId
        End If
        ' ADDED BY MOSTAFIZ ISSUE 2743

        If UGI.MarkingType.HasValue AndAlso UGI.MarkingType = -99 Then
            Dim newId = da.InsertListItem("Abno marking", UGI.MarkingTypeNewItemText)
            If newId > 0 Then UGI.MarkingType = newId
        End If

        If UGI.InjectionType.HasValue AndAlso UGI.InjectionType = -99 Then
            Dim newId = da.InsertListItem("Agent Upper GI", UGI.InjectionTypeNewItemText)
            If newId > 0 Then UGI.InjectionType = newId
        End If

        If UGI.HomeostasisType.HasValue AndAlso UGI.HomeostasisType = -99 Then
            Dim newId = da.InsertListItem("Homeostasis", UGI.HomeostasisTypeNewItemText)
            If newId > 0 Then UGI.HomeostasisType = newId
        End If

        If UGI.GastrostomyInsertionType.HasValue AndAlso UGI.GastrostomyInsertionType = -99 Then
            Dim newId = da.InsertListItem("Gastrostomy PEG type", UGI.GastrostomyInsertionTypeNewItemText)
            If newId > 0 Then UGI.GastrostomyInsertionType = newId
        End If

        If UGI.EMRFluid.HasValue AndAlso UGI.EMRFluid = -99 Then
            Dim newId = da.InsertListItem("Therapeutic EMR Fluid", UGI.EMRFluidNewItemText)
            If newId > 0 Then UGI.EMRFluid = newId
        End If

        'If UGI.DilatorType.HasValue AndAlso UGI.DilatorType = -99 Then
        '    Dim newId = da.InsertListItem("Oesophageal dilator", UGI.DilatorTypeNewItemText)
        '    If newId > 0 Then UGI.DilatorType = newId
        'End If

        If UGI.StentRemovalTechnique.HasValue AndAlso UGI.StentRemovalTechnique = -99 Then
            Dim newId = da.InsertListItem("Therapeutic Stent Removal Technique", UGI.StentRemovalTechniqueNewItemText)
            If newId > 0 Then UGI.StentRemovalTechnique = newId
        End If

        If UGI.BicapElectroType.HasValue AndAlso UGI.BicapElectroType = 0 Then
            Dim newId = da.InsertListItem("BicapElectro", UGI.BicapElectroTypeNewItemText)
            If newId > 0 Then UGI.BicapElectroType = newId
        End If
        '### 2) Now do the actual DML operations... INSERT/UPDATE/DELETE
        Using db As New ERS.Data.GastroDbEntities

            If save = SaveAs.InsertNew Then
                UGI.WhoCreatedId = CInt(HttpContext.Current.Session("PKUserID"))
                UGI.WhenCreated = Now
                Dim result = db.ERS_UpperGITherapeutics.Add(UGI)
            ElseIf save = SaveAs.Update Then
                '### Now Hapy to Update
                UGI.WhoUpdatedId = CInt(HttpContext.Current.Session("PKUserID"))
                UGI.WhenUpdated = Now
                db.ERS_UpperGITherapeutics.Attach(UGI)
                db.Entry(UGI).State = Entity.EntityState.Modified
            End If

            UGI.SiteId = HttpContext.Current.Session(Constants.SESSION_SITE_ID)

            '### Now time to play with Record Counter
            Dim ersRecord As ERS_RecordCount
            ersRecord = db.ERS_RecordCount.Where(Function(ers) ers.SiteId = UGI.SiteId And ers.Identifier = "Therapeutic Procedures").FirstOrDefault()

            If ersRecord Is Nothing Then
                ersRecord = New ERS_RecordCount

                ersRecord.ProcedureId = procedureId
                ersRecord.SiteId = UGI.SiteId
                ersRecord.Identifier = "Therapeutic Procedures"
                ersRecord.RecordCount = 1

                db.ERS_RecordCount.Add(ersRecord) '### Second INSERT in the TRANSACTION
            End If

            db.SaveChanges() '### Tell the EF to accept the Changes- the TRANSACTION of Two INSERT Request!
            da.Update_Upper_GI_Therapeutic(UGI.SiteId)
            da.Update_sites_summary(UGI.SiteId)
        End Using

    End Sub

    ''' <summary>
    ''' This is a Generic DELETE method to DELETE a record from the Therapeutic Tables, ie: ERS_ERCPTherapeutics, ERS_UpperGITherapeutics
    ''' This will also DELETE the entry in dbo.ERS_RecordCount Table- if required.
    ''' </summary>
    ''' <param name="therapType">OGD or ERCP</param>
    ''' <param name="recordId">Primary Key field</param>
    ''' <param name="SiteId">Site Id to Delete the entry from [ERS_RecordCount]</param>
    ''' <remarks></remarks>
    Public Sub TherapeuticRecord_Delete(ByVal therapType As String, ByVal recordId As Integer, ByVal SiteId As Integer)
        DataAccess.ExecuteScalerSQL("usp_TherapeuticRecordDelete", CommandType.StoredProcedure, New SqlParameter() {New SqlParameter("@TherapType", therapType), New SqlParameter("@RecordId", recordId), New SqlParameter("@SiteId", SiteId)})
    End Sub

    ' ''' <summary>
    ' ''' This will Update the RecordCounter flag in the ERS_RecordCount table
    ' ''' </summary>
    ' ''' <param name="siteId">Site Id</param>
    ' ''' <param name="InsertRecordCounter">Add or Remove the Counter?</param>
    ' ''' <remarks></remarks>
    'Sub UpdateRecordCounterTable(ByVal siteId As Integer, ByVal InsertRecordCounter As Boolean)
    '    Dim da As New DataAccess
    '    da.UpdateRecordCount(1, siteId, "Therapeutic Procedures", InsertRecordCounter) '### This call will actually Remove the Counter record from the table!
    'End Sub

    ''' <summary>
    ''' In UGI : if either "Clin Obstruction CBD" or "Image Obstruction CBD" is checked in Indications then "Decompressed the duct" is displayed under "Balloon trawl" tr
    ''' </summary>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Function ShouldDisplayDecompressedOptions(ByVal siteId As Integer) As Boolean
        Dim sqlStmt As String = "SELECT Ind.ProcedureId, S.SiteId, (CASE when Ind.ERSObstructedCBD=1 OR Ind.ERSObstructed=1 THEN 'True' ELSE 'False' END) AS ShowDecompressed " &
                                "FROM ERS_UpperGIIndications AS Ind " &
                                "INNER JOIN ERS_Sites AS S ON Ind.ProcedureId = S.ProcedureId AND S.SiteId = @SiteId;"

        Dim result As DataTable
        result = DataAccess.ExecuteSQL(sqlStmt, New SqlParameter() {New SqlParameter("@SiteId", siteId)})
        If result IsNot Nothing Then
            Return CBool(result.Rows(0).Item("ShowDecompressed") = True)
        Else
            Return False
        End If

    End Function

    ''' <summary>
    ''' if 'Duct' is selected as an Abnormaility then "Stent Placement Correctly" should displayed
    ''' </summary>
    ''' <param name="siteId">Site Id, Number</param>
    ''' <returns>Yes or No</returns>
    ''' <remarks></remarks>
    Public Function ShouldDisplayStentCorrentPlacementOptions(ByVal siteId As Integer) As Boolean
        Dim sqlStmt As String = "SELECT Abn.SiteId, Abn.Stricture, (CASE when Abn.Stricture=1 THEN 'True' ELSE 'False' END) AS ShowStentPlacementOption " &
                                "FROM dbo.ERS_ERCPAbnoDuct AS Abn " &
                                "WHERE Abn.SiteId = @SiteId;"

        Dim result As DataTable
        result = DataAccess.ExecuteSQL(sqlStmt, New SqlParameter() {New SqlParameter("@SiteId", siteId)})
        If result IsNot Nothing Then
            Return CBool(result.Rows(0).Item("ShowStentPlacementOption") = True)
        Else
            Return False
        End If

    End Function

    Public Function GetBronchoTherapeutics(siteId As Integer) As DataTable
        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("SELECT * FROM ERS_BRTTherapeutics WHERE SiteId = @SiteId", connection)
            cmd.CommandType = CommandType.Text
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

    Public Function SaveBRTTherapeuticsData(ByVal siteId As Integer,
                                            ByVal none As Boolean,
                                            ByVal stent As Boolean,
                                            ByVal stentQty As Nullable(Of Integer),
                                            ByVal stentMake As Nullable(Of Integer),
                                            ByVal valve As Boolean,
                                            ByVal valveQty As Nullable(Of Integer),
                                            ByVal valveMake As Nullable(Of Integer),
                                            ByVal coil As Boolean,
                                            ByVal coilQty As Nullable(Of Integer),
                                            ByVal coilMake As Nullable(Of Integer),
                                            ByVal yAGLaser As Boolean,
                                            ByVal yAGLaserPulses As Nullable(Of Integer),
                                            ByVal diathermy As Boolean,
                                            ByVal diathermyPulses As Nullable(Of Integer),
                                            ByVal cryotherapy As Boolean,
                                            ByVal photoDynamicTherapy As Boolean) As Integer

        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("therapeutics_brt_save", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@SiteID", siteId))
            cmd.Parameters.Add(New SqlParameter("@None", none))
            cmd.Parameters.Add(New SqlParameter("@Stent", stent))
            If stentQty.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@StentQty", stentQty))
            Else
                cmd.Parameters.Add(New SqlParameter("@StentQty", SqlTypes.SqlInt32.Null))
            End If
            If stentMake.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@StentMake", stentMake))
            Else
                cmd.Parameters.Add(New SqlParameter("@StentMake", SqlTypes.SqlInt32.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@Valve", valve))
            If valveQty.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@ValveQty", valveQty))
            Else
                cmd.Parameters.Add(New SqlParameter("@ValveQty", SqlTypes.SqlInt32.Null))
            End If
            If valveMake.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@ValveMake", valveMake))
            Else
                cmd.Parameters.Add(New SqlParameter("@ValveMake", SqlTypes.SqlInt32.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@Coil", coil))
            If coilQty.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@CoilQty", coilQty))
            Else
                cmd.Parameters.Add(New SqlParameter("@CoilQty", SqlTypes.SqlInt32.Null))
            End If
            If coilMake.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@CoilMake", coilMake))
            Else
                cmd.Parameters.Add(New SqlParameter("@CoilMake", SqlTypes.SqlInt32.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@YAGLaser", yAGLaser))
            If yAGLaserPulses.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@YAGLaserPulses", yAGLaserPulses))
            Else
                cmd.Parameters.Add(New SqlParameter("@YAGLaserPulses", SqlTypes.SqlInt32.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@Diathermy", diathermy))
            If diathermyPulses.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@DiathermyPulses", diathermyPulses))
            Else
                cmd.Parameters.Add(New SqlParameter("@DiathermyPulses", SqlTypes.SqlInt32.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@Cryotherapy", cryotherapy))
            cmd.Parameters.Add(New SqlParameter("@PhotoDynamicTherapy", photoDynamicTherapy))

            cmd.Connection.Open()
            rowsAffected = cmd.ExecuteNonQuery()
        End Using
        Return rowsAffected

    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetCystoScopyTherapeuticData(ByVal siteId As Integer) As DataTable
        Using da As New DataAccess
            Return da.ExecuteSP("Therapeutic_cystoscopy_select", New SqlParameter() {New SqlParameter("@SiteId", siteId)})
        End Using
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveCystoscopyTherapeuticData(ByVal siteId As Integer,
                                        ByVal none As Boolean,
                                        ByVal Diathermy As Boolean,
                                        ByVal DiathermyWatts As Double,
                                        ByVal DiathermyPulses As Double,
                                        ByVal DiathermySecs As Double,
                                        ByVal DiathermyKJ As Double,
                                        ByVal Laser As Boolean,
                                        ByVal LaserWatts As Double,
                                        ByVal LaserPulses As Double,
                                        ByVal LaserSecs As Double,
                                        ByVal LaserKJ As Double,
                                        ByVal Injection As Boolean, 'Added by rony tfs-4342
                                        ByVal InjectionType As Double,
                                        ByVal InjectionVolume As Double,
                                        ByVal InjectionNumber As Double,
                                        ByVal injectionTherapyNewTypeId As Integer,
                                        ByVal injectionTherapyTypeNewItemText As String) As Integer

        'Added by rony tfs-4342
        If injectionTherapyNewTypeId = -99 Then
            Dim da As New DataAccess
            Dim newId = da.InsertListItem("Agent Upper GI", injectionTherapyTypeNewItemText)
            If newId > 0 Then
                InjectionType = newId
            End If
        End If

        Dim rowsAffected As Integer


        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("Therapeutic_cystoscopy_save", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
            cmd.Parameters.Add(New SqlParameter("@None", none))
            cmd.Parameters.Add(New SqlParameter("@Diathermy", Diathermy))
            cmd.Parameters.Add(New SqlParameter("@DiathermyWatts", DiathermyWatts))
            cmd.Parameters.Add(New SqlParameter("@DiathermyPulses", DiathermyPulses))
            cmd.Parameters.Add(New SqlParameter("@DiathermySecs", DiathermySecs))
            cmd.Parameters.Add(New SqlParameter("@DiathermyKJ", DiathermyKJ))
            cmd.Parameters.Add(New SqlParameter("@Laser", Laser))
            cmd.Parameters.Add(New SqlParameter("@LaserWatts", LaserWatts))
            cmd.Parameters.Add(New SqlParameter("@LaserPulses", LaserPulses))
            cmd.Parameters.Add(New SqlParameter("@LaserSecs", LaserSecs))
            cmd.Parameters.Add(New SqlParameter("@LaserKJ", LaserKJ))
            cmd.Parameters.Add(New SqlParameter("@Injection", Injection)) 'Added by rony tfs-4342
            cmd.Parameters.Add(New SqlParameter("@InjectionType", InjectionType))
            cmd.Parameters.Add(New SqlParameter("@InjectionVolume", InjectionVolume))
            cmd.Parameters.Add(New SqlParameter("@InjectionNumber", InjectionNumber))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

            cmd.Connection.Open()
            rowsAffected = cmd.ExecuteNonQuery()
        End Using
        Return rowsAffected

    End Function
End Class


''' <summary>
''' This will share Common data for Therapeutic Records.. 
''' for Both ERCP and UGI or anything else in future!
''' </summary>
''' <remarks></remarks>
Public Class TherapeuticCommonData

    Private _noneChecked As Boolean
    Public Property NoneChecked() As String
        Get
            Return _noneChecked
        End Get
        Set(ByVal value As String)
            _noneChecked = value
        End Set
    End Property

    Private _otherText As String
    Public Property OtherText() As String
        Get
            Return _otherText
        End Get
        Set(ByVal value As String)
            _otherText = value
        End Set
    End Property

    Sub New(ByVal NoneCheckedValue As Boolean, ByVal OtherTextValue As String)
        _noneChecked = NoneCheckedValue
        _otherText = OtherTextValue
    End Sub

End Class