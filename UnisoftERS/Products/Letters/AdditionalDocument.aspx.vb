Imports System.IO
Imports Telerik.Web.UI

Public Class AdditionalDocument
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            PopulateHospitalDropDownList()
        End If
    End Sub

    Protected Sub ProcedureNameDropdown_SelectedIndexChanged(ByVal sender As Object, ByVal e As EventArgs)

    End Sub

    Private Sub PopulateHospitalDropDownList()
        Dim da As New LetterGeneration
        HospitalDropDownList.Items.Clear()
        HospitalDropDownList.Items.Insert(0, New DropDownListItem("ALL", 0))
        HospitalDropDownList.AppendDataBoundItems = True
        HospitalDropDownList.DataSource = da.GetOperatingHospitals(CInt(Session("TrustId")))
        HospitalDropDownList.DataBind()
    End Sub

    Protected Sub AdditionalDocumentListGrid_ItemDataBound(sender As Object, e As GridItemEventArgs)

    End Sub

    Protected Sub AdditionalDocumentListGrid_NeedDataSource(sender As Object, e As GridNeedDataSourceEventArgs)
        Dim da As New LetterGeneration
        AdditionalDocumentListGrid.DataSource = da.GetAdditionalDocumentList()
    End Sub

    Protected Sub lnkDownload_Click(ByVal sender As Object, ByVal e As EventArgs)
        Dim btn As RadButton = CType(sender, RadButton)
        LoadAdditionalDocument(btn.CommandArgument)
    End Sub

    Protected Sub lnkPrint_Click(ByVal sender As Object, ByVal e As EventArgs)
        Dim btn As RadButton = CType(sender, RadButton)
        LoadAdditionalDocument(btn.CommandArgument)
    End Sub

    Protected Sub AddClick(ByVal sender As Object, ByVal e As EventArgs)
        Response.Redirect("AddAdditionalDocument.aspx", False)
    End Sub

    Protected Sub LoadAdditionalDocument(AdditionalDocumentId As Int64)
        If Not AdditionalDocumentId = 0 Then
            ScriptManager.RegisterStartupScript(Me.Page, Page.GetType(), "text", "OpenPDF('" + AdditionalDocumentId.ToString() + "')", True)
        End If
    End Sub
    Protected Sub HospitalDropDownList_SelectedIndexChanged(sender As Object, e As DropDownListEventArgs)
        Dim da As New LetterGeneration
        AdditionalDocumentListGrid.DataSource = da.GetAdditionalDocumentList(HospitalDropDownList.SelectedValue)
        AdditionalDocumentListGrid.Rebind()
    End Sub

    Protected Sub CheckCreateAndClearDirectory(directoryName As String)

        If Directory.Exists(directoryName) Then
            For Each deleteFile In Directory.GetFiles(directoryName, "*.*", SearchOption.TopDirectoryOnly)
                File.Delete(deleteFile)
            Next
        Else
            Directory.CreateDirectory(directoryName)
        End If
    End Sub
End Class