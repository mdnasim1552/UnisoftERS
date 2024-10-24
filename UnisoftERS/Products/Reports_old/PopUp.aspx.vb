Imports System.Data.SqlClient
Imports System.Web
Imports Telerik.Web.UI.GridColumn
Imports System.Web.Services

Public Class PopUp
    Inherits System.Web.UI.Page
    Public FirstLoad As Boolean = True
    Private Shared QueryStr As String = ""
    Private Shared TitleStr As String = ""
    Private Shared ReportIdStr As String = ""
    Public Shared Property ReportID As String
        Get
            Return ReportIdStr
        End Get
        Set(ByVal Value As String)
            ReportIdStr = Value
        End Set
    End Property
    Public Shared Property Query As String
        Get
            Return QueryStr
        End Get
        Set(ByVal Value As String)
            QueryStr = Value
        End Set
    End Property
    Public Shared Property WindowTitle As String
        Get
            Return TitleStr
        End Get
        Set(ByVal Value As String)
            TitleStr = Value
        End Set
    End Property

    Public Function GetPopUpRows(ByVal UserID As String, ByVal rowID As String) As DataTable
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim sql As String = Query
        cmd.CommandText = sql
        cmd.Parameters.Add(New SqlParameter("@UserID", UserID))
        cmd.Parameters.Add(New SqlParameter("@RowID", UserID))
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds.Tables(0)
        Else
            Return Nothing
        End If
    End Function

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If IsNothing(Session("PKUserId")) Then
            Response.Redirect("/")
        End If
        Dim SQLQuery As String = GetValue("Select ReportQuery From ERS_Report Where ReportID='" + Request.QueryString("ReportID") + "'")
        WindowTitle = GetValue("Select ReportTitle From ERS_Report Where ReportID='" + Request.QueryString("ReportID") + "'")
        ReportID = Request.QueryString("ReportID")
        If Request.QueryString("rowID").ToString <> Nothing Then
            SQLQuery = Replace(SQLQuery, "@rowID", Request.QueryString("rowID").ToString)
        End If
        If Session("PKUserID").ToString <> Nothing Then
            SQLQuery = Replace(SQLQuery, "@UserID", Session("PKUserID").ToString)
        End If
        Query = SQLQuery
        DSPopUp.DataBind()
        GridView1.DataBind()
    End Sub
    Public Shared ReadOnly Property ConnectionStr() As String
        Get
            Return DataAccess.ConnectionStr
        End Get
    End Property

    Function GetData(ByVal sqlQuery As String) As DataTable
        Dim dsData As New DataSet

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sqlQuery, connection)
            cmd.CommandType = CommandType.Text
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsData)
        End Using

        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function
    Function GetValue(ByVal Qry As String) As String
        Dim str As String = ""
        Dim DT As DataTable = GetData(Qry)
        Dim Row As DataRow
        For Each Row In DT.Rows
            str = Row(0).ToString
            Exit For
        Next
        Return str
    End Function
End Class