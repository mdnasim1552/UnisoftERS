Imports System.Web.Services
Imports System.Web.Script.Services
Imports System.IO

Partial Class Products_UpdateSite
    Inherits PageBase
    <WebMethod()>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json)>
    Public Shared Function InsertSite(procId As String, regionId As Integer, xCd As String, yCd As String, position As String, positionSpecified As Boolean, areaNumber As String, height As String, width As String) As String
        Dim newSiteInfo As String
        Dim da As New DataAccess
        Dim ap As AntPos
        Try
            ap = CType([Enum].Parse(GetType(AntPos), position), AntPos)
            newSiteInfo = da.InsertSite(procId, regionId, CInt(xCd), CInt(yCd), ap, positionSpecified, areaNumber, height, width)

        Catch ex As Exception
            newSiteInfo = LogManager.LogManagerInstance.LogError("Error occured while inserting new site for Procedure Id " & procId, ex)
            Return "ErrorRef: " & newSiteInfo
        End Try

        Return newSiteInfo
    End Function
    <WebMethod()>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json)>
    Public Shared Function InsertLymphNodeSite(procId As String, regionId As Integer, xCd As String, yCd As String, position As String, positionSpecified As Boolean, areaNumber As String, height As String, width As String, lymphNodeId As Integer) As String
        Dim newSiteInfo As String
        Dim da As New DataAccess
        Dim ap As AntPos
        Try
            ap = CType([Enum].Parse(GetType(AntPos), position), AntPos)
            newSiteInfo = da.InsertSite(procId, regionId, CInt(xCd), CInt(yCd), ap, positionSpecified, areaNumber, height, width)

            'update to set as lymph node
            Dim lymphNodeRegionName = da.UpdateSiteAsLymphNodeSite(CInt(newSiteInfo.Split(";")(0)), lymphNodeId)

            Dim newSiteRegion = lymphNodeRegionName & " - " & newSiteInfo.Split(";")(1)
            newSiteInfo = newSiteInfo.Split(";")(0) & ";" & newSiteRegion
        Catch ex As Exception
            newSiteInfo = LogManager.LogManagerInstance.LogError("Error occured while inserting new site for Procedure Id " & procId, ex)
            Return "ErrorRef: " & newSiteInfo
        End Try

        Return newSiteInfo
    End Function


    <WebMethod()> _
     <ScriptMethod(ResponseFormat:=ResponseFormat.Json)> _
    Public Shared Function InsertImage(ImageData As String) As String
        Try
            Dim path As String = System.Web.Hosting.HostingEnvironment.MapPath("~/Images/")
            Dim fileNameWitPath As String = path + DateTime.Now.ToString().Replace("/", "-").Replace(" ", "").Replace(":", "") + ".png"
            Dim fs As New FileStream(fileNameWitPath, FileMode.Create)
            Dim bw As New BinaryWriter(fs)
            Dim data As Byte() = Convert.FromBase64String(ImageData)
            bw.Write(data)
            bw.Close()
            fs.Close()
            Return "successful"
        Catch ex As Exception
            Return "ErrorRef: " & ex.Message
        End Try
    End Function

    <WebMethod()> _
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json)> _
    Public Shared Function UpdateSite(siteId As String, regionId As Integer, xCd As String, yCd As String, position As String, positionSpecified As Boolean) As String

        Dim da As New DataAccess
        Dim ap As AntPos
        Try
            ap = CType([Enum].Parse(GetType(AntPos), position), AntPos)
            da.UpdateSite(siteId, regionId, CInt(xCd), CInt(yCd), ap, positionSpecified)

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while updating the site Id " & siteId, ex)
            Return "ErrorRef: " & errorLogRef
        End Try

        Return "site saved successfully"
    End Function

    <WebMethod()> _
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json)> _
    Public Shared Function UpdateResectedColon(ProcedureID As String, ColonResectionID As String) As String
        Dim da As New DataAccess
        Try
            da.UpdateResectedColon(CInt(ProcedureID), ColonResectionID)
            Dim dt = da.getProcedureBowelPrep(HttpContext.Current.Session(Constants.SESSION_PROCEDURE_ID))
            If dt.Rows.Count > 0 Then
                Dim dr = dt.Rows(0)
                da.saveBowelPrep(CInt(ProcedureID), dr("BowelPrepId"), dr("LeftPrepScore"), dr("RightPrepScore"), dr("TransversePrepScore"), dr("TotalPrepScore"), dr("AdditionalInfo"), dr("Quantity"), dr("EnemaId"), "") 'tfs 4158 
            End If

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving resected colon the procedure Id " & ProcedureID, ex)
            Return "ErrorRef: " & errorLogRef
        End Try
        Return "Resected colon saved successfully"
    End Function

    <WebMethod(EnableSession:=True)>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json)>
    Public Shared Function DeleteSite(siteId As String) As String
        Dim da As New DataAccess
        Try
            'Check for images linked to the site. If there are any, they need to be moved back to the cache folder
            Dim dtPhotos As DataTable = da.GetSitePhotos(siteId, 0) ' no need to pass procedureID as we have the site ID
            Dim tempUNC As String = HttpContext.Current.Session(Constants.SESSION_PHOTO_UNC) & "\ERS\Photos\" & HttpContext.Current.Session(Constants.SESSION_PROCEDURE_ID) & "\Temp"
            Dim procUNC As String = HttpContext.Current.Session(Constants.SESSION_PHOTO_UNC) & "\ERS\Photos\" & HttpContext.Current.Session(Constants.SESSION_PROCEDURE_ID)
            For Each dr As DataRow In dtPhotos.Rows
                dr("PhotoName").ToString()
                If File.Exists(procUNC & "\" & dr("PhotoName").ToString()) Then
                    File.Move(procUNC & "\" & dr("PhotoName").ToString(), tempUNC & "\" & dr("PhotoName").ToString())
                End If
            Next

            da.DeleteSite(siteId)

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while deleting the site Id " & siteId, ex)
            Return "ErrorRef: " & errorLogRef
        End Try

        Return "site deleted successfully"
    End Function

    <WebMethod()> _
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json)> _
    Public Shared Function GetSiteTitles(procId As String) As String
        Dim sitesJson As String = String.Empty

        sitesJson = GetSiteTitlesDataJson(procId)

        Return sitesJson
    End Function

    Private Shared Function GetSiteTitlesDataJson(procId As Integer) As String
        Dim dtSites As DataTable
        Dim da As New DataAccess
        dtSites = da.GetSiteTitles(procId)
        Return DataTableToJson(dtSites)
    End Function

    Private Shared Function DataTableToJson(dt As DataTable) As String
        Dim serializer As System.Web.Script.Serialization.JavaScriptSerializer = New System.Web.Script.Serialization.JavaScriptSerializer()
        Dim rows As New List(Of Dictionary(Of String, Object))
        Dim row As Dictionary(Of String, Object)

        For Each dr As DataRow In dt.Rows
            row = New Dictionary(Of String, Object)
            For Each col As DataColumn In dt.Columns
                row.Add(col.ColumnName, dr(col))
            Next
            rows.Add(row)
        Next
        Return serializer.Serialize(rows)
    End Function
End Class


