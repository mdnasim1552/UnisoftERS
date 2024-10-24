Imports System.Web.Services
Imports System.Data.SqlClient

Public Class WebMethods
    Inherits System.Web.UI.Page
    Public Shared ReadOnly Property ConnectionStr() As String
        Get
            Return DataAccess.ConnectionStr
        End Get
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

    End Sub
    '<WebMethod()> _
    'Public Shared Function ReportAudit(GroupName As String, ColumnName As String, ConsultantName As String, QueryText As String, Filename As String, ErrorCondition As Boolean) As String
    '    With New ReportAuditManager
    '        .EventType = EVENT_TYPE_ENUM.EventSearch
    '        .ApplicationID = APP_ID_ENUM.AppAuditLog
    '        .GroupName = GroupName
    '        .ColumnName = ColumnName
    '        .ConsultantName = ConsultantName
    '        .QueryText = QueryText
    '        .Filename = Filename
    '        .ErrorCondition = ErrorCondition
    '        .SaveAuditLog()
    '    End With
    '    Return Nothing
    'End Function
    <WebMethod()> _
    Public Shared Function getMenuXML(ByVal Group As String, ByVal columnName As String) As String
        Dim XMLstr As String = "<MenuItems>"
        Dim sqlstr As String = "Select G.ReportGroupID+C.ColumnName As [Key], C.ColumnName, R.ReportID As Value, R.[Text] As [Text], R.ToolTip As [ToolTip] "
        sqlstr += "From ERS_ReportPopup P "
        sqlstr += ", ERS_Report R "
        sqlstr += ", ERS_ReportGroupColumn C "
        sqlstr += ", ERS_ReportGroup G "
        sqlstr += "Where P.ReportID=R.ReportID And C.ReportGroupColumnID=P.ReportGroupColumnID And G.ReportGroupID=C.ReportGroupID And G.ReportGroupID='" + Group + "' And C.ColumnName='" + columnName + "'"
        Dim dsData As New DataSet
        Dim row As DataRow
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sqlstr, connection)
            cmd.CommandType = CommandType.Text
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
            For Each row In dsData.Tables(0).Rows
                Try
                    XMLstr += "<row Key=""EndoscopistID"" ReportGroupID=""" + Group + """ ColumnName=""" + row("ColumnName") + """ Value=""" + row("Value") + """ Text=""" + row("Text") + """ ToolTip=""" + row("ToolTip") + """ />"
                Catch ex As Exception
                End Try
            Next row
        End Using
        dsData.Dispose()
        XMLstr += "</MenuItems>"
        Return XMLstr
    End Function
    <WebMethod()> _
    Public Shared Function getDefaultColumnReport(ByVal Group As String, ByVal columnName As String) As String
        Dim XMLstr As String = ""
        Dim sqlstr As String = "Select ReportID From ERS_ReportGroupColumn Where ReportGroupID='" + Group + "' And ColumnName='" + columnName + "'"
        'sqlstr += " And G.ReportGroupID='" + Group + "' And C.ColumnName='" + columnName + "'"
        Dim dsData As New DataSet
        Dim row As DataRow
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sqlstr, connection)
            cmd.CommandType = CommandType.Text
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
            For Each row In dsData.Tables(0).Rows
                Try
                    XMLstr = row("ReportID")
                    Exit For
                Catch ex As Exception
                End Try
            Next row
        End Using
        dsData.Dispose()
        Return XMLstr
    End Function
    <WebMethod()> _
    Public Shared Function getReportTarget(ByVal ReportID As String) As String
        Dim XMLstr As String = ""
        Dim sqlstr As String = "Select ReportTargetID From ERS_Report Where ReportID='" + ReportID + "'"
        Dim dsData As New DataSet
        Dim row As DataRow
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sqlstr, connection)
            cmd.CommandType = CommandType.Text
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
            For Each row In dsData.Tables(0).Rows
                Try
                    XMLstr = row("ReportTargetID")
                    Exit For
                Catch ex As Exception
                End Try
            Next row
        End Using
        dsData.Dispose()
        Return XMLstr
    End Function
    '<WebMethod()> _
    'Public Shared Function GetAuditorsMenus(ReportColumnGroupID As String, ReportName As String) As List(Of String)
    '    Dim ds As New DataAccess
    '    Return ds.GetAuditorsMenu(ReportColumnGroupID, ReportName)
    'End Function
    <WebMethod()> _
    Public Shared Function getConsultants(ByVal listboxNo As String, ByVal ConsultantType As String, ByVal HideSuppressed As String, ByVal UserID As String) As String
        Dim XMLstr As String = "<Consultants>"
        Dim sqlstr As String = "SELECT ReportID, Consultant, Active, IsListConsultant, IsEndoscopist1, IsEndoscopist2, IsAssistantOrTrainee, IsNurse1, IsNurse2 FROM v_rep_JAG_Consultants WHERE (Consultant <> '(None)')"
        Select Case ConsultantType
            Case "All"
            Case "Endoscopist 1"
                sqlstr = sqlstr + " And IsEndoscopist1='1'"
            Case "Endoscopist 2"
                sqlstr = sqlstr + " And IsEndoscopist2='1'"
            Case "List Consultant"
                sqlstr = sqlstr + " And IsListConsultant='1'"
            Case "Assistants or trainees"
                sqlstr = sqlstr + " And IsAssistantOrTrainee='1'"
            Case "Nurse 1"
                sqlstr = sqlstr + " And IsNurse1='1'"
            Case "Nurse 2"
                sqlstr = sqlstr + " And IsNurse2='1'"
        End Select
        If HideSuppressed = "1" Then
            sqlstr = sqlstr + " And Active='1'"
        End If
        Dim dsData As New DataSet
        Dim row As DataRow
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sqlstr, connection)
            cmd.CommandType = CommandType.Text
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
            For Each row In dsData.Tables(0).Rows
                Try
                    XMLstr += "<row ReportID=""" + row("ReportID").ToString + """ Consultant=""" + row("Consultant").ToString + """ />"
                Catch ex As Exception
                    MsgBox(ex.Message)
                End Try
            Next row
        End Using
        dsData.Dispose()
        XMLstr += "</Consultants>"
        Return XMLstr
    End Function
    '<WebMethod()> _
    'Public Shared Function GetAuditorsDefaultReport(ReportColumnGroupID As String, ReportName As String) As String
    '    Dim ds As New DataAccess
    '    Return ds.GetAuditorsDefaultReports(ReportColumnGroupID, ReportName)
    'End Function
End Class