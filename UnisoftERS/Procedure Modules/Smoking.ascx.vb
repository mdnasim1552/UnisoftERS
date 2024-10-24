Imports Telerik.Web.UI

Public Class Smoking
    Inherits ProcedureControls

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        If Page.IsPostBack = False Then

            Dim dt As DataTable = DataAdapter.GetSmokingType()
            For Each dr As DataRow In dt.Rows
                Dim item As New RadComboBoxItem
                item.Text = dr("SmokingTypeName")
                item.Value = dr("SmokingTypeId")
                item.Attributes.Add("SmokingTypeAverageDescription", dr("SmokingTypeAverageDescription"))
                SmokingTypedropdown.Items.Add(item)
            Next

            '  SmokingTypedropdown.DataSource = DataAdapter.GetSmokingType()
            '  SmokingTypedropdown.DataBind()
            SmokingLst.DataSource = DataAdapter.GetSmokingDetails(Session(Constants.SESSION_PROCEDURE_ID))
            SmokingLst.DataBind()
            SmokingLst.Items.Insert(0, New RadListBoxItem("", 0))
        End If
    End Sub
End Class