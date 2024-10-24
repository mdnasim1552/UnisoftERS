Imports Telerik.Web.UI

Public Class ListLetterTemplate
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            PopulateHospitalDropDownList()
        End If
    End Sub
    Protected Sub HospitalDropDownList_SelectedIndexChanged(sender As Object, e As DropDownListEventArgs)
        Dim da As New LetterGeneration
        TemplateListGrid.DataSource = da.GetLetterTemplateList(HospitalDropDownList.SelectedValue)
        TemplateListGrid.Rebind()
    End Sub
    Protected Sub TemplateListGrid_ItemDataBound(sender As Object, e As GridItemEventArgs)

    End Sub
    Protected Sub TemplateListGrid_NeedDataSource(sender As Object, e As GridNeedDataSourceEventArgs)
        Dim da As New LetterGeneration
        TemplateListGrid.DataSource = da.GetLetterTemplateList()
    End Sub
    Protected Sub AddClick(ByVal sender As Object, ByVal e As EventArgs)

        Response.Redirect("LetterTemplate.aspx", False)


    End Sub


    Private Sub PopulateHospitalDropDownList()
        Dim da As New LetterGeneration
        HospitalDropDownList.Items.Clear()
        HospitalDropDownList.Items.Insert(0, New DropDownListItem("ALL", 0))
        HospitalDropDownList.AppendDataBoundItems = True
        HospitalDropDownList.DataSource = da.GetOperatingHospitals(CInt(Session("TrustId")))
        HospitalDropDownList.DataBind()
    End Sub
End Class