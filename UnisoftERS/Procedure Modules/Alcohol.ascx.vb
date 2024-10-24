Imports System.Data.Common
Imports Telerik.Web.UI

Public Class Alcohol
    Inherits ProcedureControls

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Page.IsPostBack = False Then
            Dim dt As DataTable = DataAdapter.GetAlcoholingType()
            For Each dr As DataRow In dt.Rows
                Dim item As New RadComboBoxItem
                item.Text = dr("AlcoholingTypeName")
                item.Value = dr("AlcoholingTypeId")
                item.Attributes.Add("AlcoholingTypeAverageDescription", dr("AlcoholingTypeAverageDescription"))
                AlcoholTypedropdown.Items.Add(item)
            Next

            '  SmokingTypedropdown.DataSource = DataAdapter.GetSmokingType()
            '  SmokingTypedropdown.DataBind()
            AlcoholLst.DataSource = DataAdapter.GetAlcoholingDetails(Session(Constants.SESSION_PROCEDURE_ID))
            AlcoholLst.DataBind()
            AlcoholLst.Items.Insert(0, New RadListBoxItem("", 0))
        End If
    End Sub

End Class