Imports UnisoftERS.NedClass
Imports System.IO
Imports System.Xml
Imports System.Data.SqlClient

Public Class xmlW
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Request.QueryString("LogId") <> "" Then
            xmlText.Text = NedClass.GetXML_ExportedDataById(Request.QueryString("LogId"))
        End If
    End Sub

End Class