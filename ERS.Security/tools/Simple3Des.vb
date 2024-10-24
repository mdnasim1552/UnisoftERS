Imports System.Security.Cryptography
Imports System.Data.SqlClient
Imports System.Configuration

Public NotInheritable Class Simple3Des
    Implements IDisposable

    Private TripleDes As New TripleDESCryptoServiceProvider
    Private DESKey As String = "un116.205g053#"
    Private Shared _decryptedConnectionStringADO As String '### Will keep a copy of ENglish Connection string for the use of Entity Framework
    Private Shared _decryptedPassword As String
    Private Shared _databaseName As String
    Private Shared _userId As String
    Private Shared _dbServerName As String

    Sub New(ByVal key As String)
        ' Initialize the crypto provider.
        TripleDes.Key = TruncateHash(key, TripleDes.KeySize \ 8)
        TripleDes.IV = TruncateHash("", TripleDes.BlockSize \ 8)
    End Sub
    Private Function TruncateHash(ByVal key As String, ByVal length As Integer) As Byte()

        Dim sha1 As New SHA1CryptoServiceProvider

        ' Hash the key.
        Dim keyBytes() As Byte =
            System.Text.Encoding.Unicode.GetBytes(key)
        Dim hash() As Byte = sha1.ComputeHash(keyBytes)

        ' Truncate or pad the hash.
        ReDim Preserve hash(length - 1)
        Return hash
    End Function
    Private Function EncryptData(ByVal plaintext As String) As String

        ' Convert the plaintext string to a byte array.
        Dim plaintextBytes() As Byte =
            System.Text.Encoding.Unicode.GetBytes(plaintext)

        ' Create the stream.
        Dim ms As New System.IO.MemoryStream
        ' Create the encoder to write to the stream.
        Dim encStream As New CryptoStream(ms,
            TripleDes.CreateEncryptor(),
            System.Security.Cryptography.CryptoStreamMode.Write)

        ' Use the crypto stream to write the byte array to the stream.
        encStream.Write(plaintextBytes, 0, plaintextBytes.Length)
        encStream.FlushFinalBlock()

        ' Convert the encrypted stream to a printable string.
        Return Convert.ToBase64String(ms.ToArray)
    End Function
    Public Function DecryptData(ByVal encryptedtext As String) As String

        ' Convert the encrypted text string to a byte array.
        Dim encryptedBytes() As Byte = Convert.FromBase64String(encryptedtext)

        ' Create the stream.
        Dim ms As New System.IO.MemoryStream
        ' Create the decoder to write to the stream.
        Dim decStream As New CryptoStream(ms,
            TripleDes.CreateDecryptor(),
            System.Security.Cryptography.CryptoStreamMode.Write)

        ' Use the crypto stream to write the byte array to the stream.
        decStream.Write(encryptedBytes, 0, encryptedBytes.Length)
        decStream.FlushFinalBlock()

        ' Convert the plaintext stream to a string.
        Return System.Text.Encoding.Unicode.GetString(ms.ToArray)
    End Function

    Public Function ConnectionStringBuilder(ConnectionStrg As String, Optional isEncrypted As Boolean = True) As String
        Dim builder As New SqlConnectionStringBuilder(ConnectionStrg)
        If Not String.IsNullOrEmpty(builder.Password) Then
            If isEncrypted Then
                Dim Encrypto As New ERS.Security.Simple3Des(DESKey)
                _decryptedPassword = Encrypto.DecryptData(builder.Password) '## Store it for Later use- for Entity Framework!
                builder.Password = _decryptedPassword
            Else
                _decryptedPassword = builder.Password
            End If
            _databaseName = builder.InitialCatalog.ToString()
            _dbServerName = builder.DataSource.ToString()
            _userId = builder.UserID.ToString()
        End If
        Return builder.ConnectionString
    End Function


    Public Property ConnectionStrMainDB(ByVal _encryptedConnectionString As String, Optional ByVal _IsEncrypted As Boolean = True) As String
        Get
            If Not IsNothing(_encryptedConnectionString) Then
                Using Securitee As New ERS.Security.Simple3Des("")
                    _decryptedConnectionStringADO = ConnectionStringBuilder(_encryptedConnectionString, _IsEncrypted)
                    Return _decryptedConnectionStringADO
                End Using
            Else
                Return Nothing
            End If
        End Get
        Set(value As String)
            _encryptedConnectionString = value
        End Set
    End Property

    Public ReadOnly Property ConnectionStringPassword() As String
        Get
            Return _decryptedPassword
        End Get

    End Property

    ''' <summary>
    ''' This will Build the Enitity Framework Connection String- putting the necessary blocks in place!
    ''' </summary>
    ''' <param name="rawConnectionString">Connection String Template to fill proper values in it!</param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Function BuildEFConnectionString(ByVal rawConnectionString As String) As String
        Return String.Format(rawConnectionString, _dbServerName, _databaseName, _userId, _decryptedPassword)
    End Function


    Public ReadOnly Property ConnectionStrPASData() As String
        Get
            Return ConnectionStringBuilder("PASData")
            'Using Securitee As New ERS.Security.Simple3Des("")
            '    Return Securitee.ConnectionStringBuilder(ConfigurationManager.ConnectionStrings("PASData").ConnectionString)
            'End Using
        End Get
    End Property

    Public Sub Dispose() Implements IDisposable.Dispose
        GC.SuppressFinalize(Me)
    End Sub

    Protected Overrides Sub Finalize()
        Dispose()
        'Console.WriteLine("Object " & GetHashCode() & " finalized.")
    End Sub


End Class

