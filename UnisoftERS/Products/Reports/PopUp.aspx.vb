Imports System.Data.SqlClient
Imports System.Web
Imports Telerik.Web.UI.GridColumn
Imports System.Web.Services

Public Class PopUp
    Inherits System.Web.UI.Page
    Public FirstLoad As Boolean = True
    Private QueryStr As String = ""
    Private TitleStr As String = ""
    Private ReportIdStr As String = ""

    Public Property ReportID As String
        Get
            Return ReportIdStr
        End Get
        Set(ByVal Value As String)
            ReportIdStr = Value
        End Set
    End Property

    Public Property Query As String
        Get
            If String.IsNullOrWhiteSpace(QueryStr) Then
                Dim procedureTypeId As Integer = Integer.Parse(HttpContext.Current.Request.QueryString("procedureTypeId"))
                Dim columnName As String = HttpContext.Current.Request.QueryString("columnName")

                If columnName <> Nothing And procedureTypeId <> Nothing Then
                    If columnName.Contains("70Years") Then
                        QueryStr = "exec [dbo].[report_JAGDrugs] @UserId, @AnonimizedId, @ProcedureTypeId, @DrugName, @Age"
                    ElseIf columnName = "NumberOfProcedures" Then
                        QueryStr = "exec [dbo].[report_JAGNumberOfProcedures] @UserId, @AnonimizedId, @ProcedureTypeId"
                    ElseIf columnName = "ComfortScoreGT4P" Then
                        QueryStr = "exec [dbo].[report_JAGComfortScoreGT4P] @UserId, @AnonimizedId, @ProcedureTypeId"
                    Else
                        Dim reportName As String
                        Select Case procedureTypeId
                            Case 1
                                reportName = "JAGOGD" + columnName
                            Case 2
                                reportName = "JAGERC" + columnName
                            Case 3
                                reportName = "JAGCOL" + columnName
                            Case 4
                                reportName = "JAGSIG" + columnName
                            Case 15
                                reportName = "JAGPEG" + columnName
                            Case Else
                                reportName = "JAG" + columnName
                        End Select

                        QueryStr = "exec [dbo].[report_" + reportName + "] @UserId, @AnonimizedId, @ProcedureTypeId"
                    End If
                End If
            End If

            Return QueryStr
        End Get
        Set(ByVal Value As String)
            QueryStr = Value
        End Set
    End Property

    Public Property WindowTitle As String
        Get
            Return TitleStr
        End Get
        Set(ByVal Value As String)
            TitleStr = Value
        End Set
    End Property

    Public Function GetPopUpRows(ByVal AnonimizedId As Integer, ByVal ColumnName As String, ByVal ProcedureTypeId As Integer) As DataTable
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim sql As String = Query
        cmd.CommandText = sql
        cmd.Parameters.Add(New SqlParameter("@UserId", Integer.Parse(Session("PKUserId"))))
        cmd.Parameters.Add(New SqlParameter("@AnonimizedId", AnonimizedId))
        cmd.Parameters.Add(New SqlParameter("@ProcedureTypeId", ProcedureTypeId))
        If ColumnName <> Nothing And (ColumnName.Contains("LT70") Or ColumnName.Contains("GE70")) Then
            Dim drugSplit As String() = ColumnName.Split("_")
            If drugSplit.Count = 2 Then
                Dim age As String = ""
                If drugSplit(0).Contains("LT70") Then
                    age = "LT70"
                ElseIf drugSplit(0).Contains("GE70") Then
                    age = "GE70"
                End If
                cmd.Parameters.Add(New SqlParameter("@DrugName", drugSplit(1)))
                cmd.Parameters.Add(New SqlParameter("@Age", age))
            End If
        End If
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
            Response.Redirect("/", False)
        End If
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