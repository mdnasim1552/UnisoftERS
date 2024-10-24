Imports Telerik.Web.UI

Public Class ExistingPatients
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            Dim patientIDs = Request.QueryString("ids").ToString().Split(",").ToList
            Dim da As New DataAccess
            PatientsListGrid.DataSource = da.GetPatientsByIDs(patientIDs)
            PatientsListGrid.DataBind()
        End If
    End Sub

    Protected Sub PatientsListGrid_ItemDataBound(sender As Object, e As GridItemEventArgs)
        If e.Item.DataItem IsNot Nothing Then
            CType(e.Item.DataItem, GridDataItem)("NHSNo").Text = Utilities.FormatHealthServiceNumber(CType(e.Item.DataItem, GridDataItem)("NHSNo").Text)
        End If
    End Sub

    Private Sub PatientsListGrid_PreRender(sender As Object, e As EventArgs) Handles PatientsListGrid.PreRender
        Dim headerText = PatientsListGrid.MasterTableView.GetColumn("NHSNo").HeaderText

        If headerText = "NHS no." Then
            PatientsListGrid.MasterTableView.GetColumn("NHSNo").HeaderText = Session(Constants.SESSION_HEALTH_SERVICE_NAME).ToString().ToUpper() + " no."
            PatientsListGrid.MasterTableView.Rebind()
        End If
    End Sub

End Class