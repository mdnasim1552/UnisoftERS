Imports System.Configuration
Imports System.Data.Entity.Core.EntityClient
Imports System.Data.SqlClient
Imports System.Data.Entity

''' <summary>
''' This is a Partial Class to Customise Entity Framework Conection String..
''' To Decrypt the password.
''' And to build the Dynamic Connection string - copied from ADO.Net connection string.#So- Server, Database, UID and Password all the values will be copied from ADO.Net connection string, from Web.Config file!
''' Shawkat Osman;; 2017-07-18
''' </summary>
''' <remarks></remarks>
Partial Public Class GastroDbEntities
    Inherits DbContext

    Public Sub New()
        MyBase.New(GetEntityConnectionString())
    End Sub

    Private Shared Function GetEntityConnectionString() As String
        Dim efConnectionString As String = ConfigurationManager.ConnectionStrings("GastroDbEntities").ConnectionString()

        Using Securitee As New ERS.Security.Simple3Des("")        
            efConnectionString = Securitee.BuildEFConnectionString(efConnectionString)
        End Using

        Return efConnectionString

    End Function

End Class
