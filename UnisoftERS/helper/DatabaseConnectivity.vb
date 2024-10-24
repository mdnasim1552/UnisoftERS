Imports System.Data.SqlClient

'protected void TestAdoHelper()
'{
'    string qry = "SELECT ArtID, ArtTitle, ArtSlug" +
'        " FROM Article WHERE ArtApproved = @Approved AND ArtUpdated > @Updated";

'    using (AdoHelper db = new AdoHelper())
'    using (SqlDataReader rdr = db.ExecDataReader(qry, "@Approved", true,
'        "@Updated", new DateTime(2011, 3, 1)))
'    {
'        while (rdr.Read())
'        {
'            // Get row of data from rdr
'        }
'    }
'}


''' <summary>
''' An ADO.NET helper class
''' </summary>
Public Class DatabaseConnectivity
    Implements IDisposable

    ' Internal members
    Protected _connString As String = Nothing
    Protected _conn As SqlConnection = Nothing
    Protected _trans As SqlTransaction = Nothing
    Protected _disposed As Boolean = False

    ''' <summary>
    ''' Sets or returns the connection string use by all instances of this class.
    ''' </summary>
    Public Shared Property ConnectionString() As String
        Get
            Return m_ConnectionString
        End Get
        Set(value As String)
            m_ConnectionString = value
        End Set
    End Property
    Private Shared m_ConnectionString As String = System.Configuration.ConfigurationManager.ConnectionStrings("Gastro_DB").ConnectionString.ToString()

    ''' <summary>
    ''' Returns the current SqlTransaction object or null if no transaction
    ''' is in effect.
    ''' </summary>
    Public ReadOnly Property Transaction() As SqlTransaction
        Get
            Return _trans
        End Get
    End Property

    ''' <summary>
    ''' Constructor using global connection string.
    ''' </summary>
    Public Sub New()
        _connString = ConfigurationManager.ConnectionStrings("Gastro_DB").ConnectionString.ToString()
        Connect()
    End Sub

    ''' <summary>
    ''' Constructure using connection string override
    ''' </summary>
    ''' <param name="connString">Connection string for this instance</param>
    Public Sub New(connString As String)
        _connString = connString
        Connect()
    End Sub

    ' Creates a SqlConnection using the current connection string
    Protected Sub Connect()
        _conn = New SqlConnection(_connString)
        _conn.Open()
    End Sub

    ''' <summary>
    ''' Constructs a SqlCommand with the given parameters. This method is normally called
    ''' from the other methods and not called directly. But here it is if you need access
    ''' to it.
    ''' </summary>
    ''' <param name="qry">SQL query or stored procedure name</param>
    ''' <param name="type">Type of SQL command</param>
    ''' <param name="args">Query arguments. Arguments should be in pairs where one is the
    ''' name of the parameter and the second is the value. The very last argument can
    ''' optionally be a SqlParameter object for specifying a custom argument type</param>
    ''' <returns></returns>
    Public Function CreateCommand(qry As String, type As CommandType, ParamArray args As Object()) As SqlCommand
        Dim cmd As New SqlCommand(qry, _conn)

        ' Associate with current transaction, if any
        If _trans IsNot Nothing Then
            cmd.Transaction = _trans
        End If

        ' Set command type
        cmd.CommandType = type

        ' Construct SQL parameters
        For i As Integer = 0 To args.Length - 1
            If TypeOf args(i) Is String AndAlso i < (args.Length - 1) Then
                Dim parm As New SqlParameter()
                parm.ParameterName = DirectCast(args(i), String)
                parm.Value = args(System.Threading.Interlocked.Increment(i))
                cmd.Parameters.Add(parm)
            ElseIf TypeOf args(i) Is SqlParameter Then
                cmd.Parameters.Add(DirectCast(args(i), SqlParameter))
            Else
                Throw New ArgumentException("Invalid number or type of arguments supplied")
            End If
        Next
        Return cmd
    End Function

#Region "Exec Members"

    ''' <summary>
    ''' Executes a query that returns no results
    ''' </summary>
    ''' <param name="qry">Query text</param>
    ''' <param name="args">Any number of parameter name/value pairs and/or SQLParameter arguments</param>
    ''' <returns>The number of rows affected</returns>
    Public Function ExecNonQuery(qry As String, ParamArray args As Object()) As Integer
        Using cmd As SqlCommand = CreateCommand(qry, CommandType.Text, args)
            Return cmd.ExecuteNonQuery()
        End Using
    End Function

    ''' <summary>
    ''' Executes a stored procedure that returns no results
    ''' </summary>
    ''' <param name="proc">Name of stored proceduret</param>
    ''' <param name="args">Any number of parameter name/value pairs and/or SQLParameter arguments</param>
    ''' <returns>The number of rows affected</returns>
    Public Function ExecNonQueryProc(proc As String, ParamArray args As Object()) As Integer
        Using cmd As SqlCommand = CreateCommand(proc, CommandType.StoredProcedure, args)
            Return cmd.ExecuteNonQuery()
        End Using
    End Function

    ''' <summary>
    ''' Executes a query that returns a single value
    ''' </summary>
    ''' <param name="qry">Query text</param>
    ''' <param name="args">Any number of parameter name/value pairs and/or SQLParameter arguments</param>
    ''' <returns>Value of first column and first row of the results</returns>
    Public Function ExecScalar(qry As String, ParamArray args As Object()) As Object
        Using cmd As SqlCommand = CreateCommand(qry, CommandType.Text, args)
            Return cmd.ExecuteScalar()
        End Using
    End Function

    ''' <summary>
    ''' Executes a query that returns a single value
    ''' </summary>
    ''' <param name="proc">Name of stored proceduret</param>
    ''' <param name="args">Any number of parameter name/value pairs and/or SQLParameter arguments</param>
    ''' <returns>Value of first column and first row of the results</returns>
    Public Function ExecScalarProc(qry As String, ParamArray args As Object()) As Object
        Using cmd As SqlCommand = CreateCommand(qry, CommandType.StoredProcedure, args)
            Return cmd.ExecuteScalar()
        End Using
    End Function

    ''' <summary>
    ''' Executes a query and returns the results as a SqlDataReader
    ''' </summary>
    ''' <param name="qry">Query text</param>
    ''' <param name="args">Any number of parameter name/value pairs and/or SQLParameter arguments</param>
    ''' <returns>Results as a SqlDataReader</returns>
    Public Function ExecDataReader(qry As String, ParamArray args As Object()) As SqlDataReader
        Using cmd As SqlCommand = CreateCommand(qry, CommandType.Text, args)
            Return cmd.ExecuteReader()
        End Using
    End Function

    ''' <summary>
    ''' Executes a stored procedure and returns the results as a SqlDataReader
    ''' </summary>
    ''' <param name="proc">Name of stored proceduret</param>
    ''' <param name="args">Any number of parameter name/value pairs and/or SQLParameter arguments</param>
    ''' <returns>Results as a SqlDataReader</returns>
    Public Function ExecDataReaderProc(qry As String, ParamArray args As Object()) As SqlDataReader
        Using cmd As SqlCommand = CreateCommand(qry, CommandType.StoredProcedure, args)
            Return cmd.ExecuteReader()
        End Using
    End Function

    ''' <summary>
    ''' Executes a query and returns the results as a DataSet
    ''' </summary>
    ''' <param name="qry">Query text</param>
    ''' <param name="args">Any number of parameter name/value pairs and/or SQLParameter arguments</param>
    ''' <returns>Results as a DataSet</returns>
    Public Function ExecDataSet(qry As String, ParamArray args As Object()) As DataSet
        Using cmd As SqlCommand = CreateCommand(qry, CommandType.Text, args)
            Dim adapt As New SqlDataAdapter(cmd)
            Dim ds As New DataSet()
            adapt.Fill(ds)
            Return ds
        End Using
    End Function

    ''' <summary>
    ''' Executes a stored procedure and returns the results as a Data Set
    ''' </summary>
    ''' <param name="proc">Name of stored proceduret</param>
    ''' <param name="args">Any number of parameter name/value pairs and/or SQLParameter arguments</param>
    ''' <returns>Results as a DataSet</returns>
    Public Function ExecDataSetProc(qry As String, ParamArray args As Object()) As DataSet
        Using cmd As SqlCommand = CreateCommand(qry, CommandType.StoredProcedure, args)
            Dim adapt As New SqlDataAdapter(cmd)
            Dim ds As New DataSet()
            adapt.Fill(ds)
            Return ds
        End Using
    End Function

#End Region

#Region "Transaction Members"

    ''' <summary>
    ''' Begins a transaction
    ''' </summary>
    ''' <returns>The new SqlTransaction object</returns>
    Public Function BeginTransaction() As SqlTransaction
        Rollback()
        _trans = _conn.BeginTransaction()
        Return Transaction
    End Function

    ''' <summary>
    ''' Commits any transaction in effect.
    ''' </summary>
    Public Sub Commit()
        If _trans IsNot Nothing Then
            _trans.Commit()
            _trans = Nothing
        End If
    End Sub

    ''' <summary>
    ''' Rolls back any transaction in effect.
    ''' </summary>
    Public Sub Rollback()
        If _trans IsNot Nothing Then
            _trans.Rollback()
            _trans = Nothing
        End If
    End Sub

#End Region

#Region "IDisposable Members"

    Public Sub Dispose() Implements IDisposable.Dispose
        Dispose(True)
        GC.SuppressFinalize(Me)
    End Sub

    Protected Overridable Sub Dispose(disposing As Boolean)
        If Not _disposed Then
            ' Need to dispose managed resources if being called manually
            If disposing Then
                If _conn IsNot Nothing Then
                    Rollback()
                    _conn.Dispose()
                    _conn = Nothing
                End If
            End If
            _disposed = True
        End If
    End Sub

#End Region

End Class

