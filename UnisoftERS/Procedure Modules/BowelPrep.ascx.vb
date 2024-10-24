Imports System.Data.SqlClient
Imports Telerik.Web.UI

Public Class BowelPrep
    Inherits ProcedureControls

    Private conn As SqlConnection = Nothing
    Private myReader As SqlDataReader = Nothing
    Private ProcType As Integer

    Protected Property BowelPrepValue() As Boolean
        Get
            Return CBool(ViewState("BowelPrepValue"))
        End Get
        Set(ByVal value As Boolean)
            ViewState("BowelPrepValue") = value
        End Set
    End Property

    Protected Property DrugAdminValidation() As Boolean
        Get
            Return CBool(ViewState("DrugAdminValidation"))
        End Get
        Set(ByVal value As Boolean)
            ViewState("DrugAdminValidation") = value
        End Set
    End Property

    Protected Property BowelPrepValidation() As Boolean
        Get
            Return CBool(ViewState("BowelPrepValidation"))
        End Get
        Set(ByVal value As Boolean)
            ViewState("BowelPrepValidation") = value
        End Set
    End Property

    Protected Sub Page_Load(sender As Object, e As System.EventArgs) Handles Me.PreRender
        ProcType = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))

        If Not Page.IsPostBack Then
            BowelPrepQtyRadNumericTextBox.MaxValue = Integer.MaxValue
            LoadBowelPrep()
        End If
    End Sub

    Private Sub LoadBowelPrep()
        Try
            Dim da As New DataAccess

            FormationComboBox.DataSource = da.LoadBowelPrep()
            FormationComboBox.DataBind()

            Dim enemaFormulas = da.LoadEnemaBowelPrep()

            If enemaFormulas IsNot Nothing AndAlso enemaFormulas.Rows.Count > 0 Then
                For Each dr As DataRow In enemaFormulas.Rows
                    Dim cbi As New RadComboBoxItem
                    With cbi
                        .Text = dr("Description")
                        .Value = dr("UniqueId")
                        .Attributes.Add("data-defaultvolume", dr("Volume"))
                    End With
                    EnemaFormationComboBox.Items.Add(cbi)
                Next
            End If


            Dim dt = da.getProcedureBowelPrep(Session(Constants.SESSION_PROCEDURE_ID))
            If dt.Rows.Count > 0 Then
                Dim dr = dt.Rows(0)
                FormationComboBox.SelectedIndex = FormationComboBox.Items.FindItemIndexByValue(dr("bowelPrepId"))
                EnemaFormationComboBox.SelectedIndex = EnemaFormationComboBox.Items.FindItemIndexByValue(dr("enemaId"))
                'If Not dr.IsNull("AdditionalInfo") Then OtherBowelPrepRadTextBox.Text = dr("AdditionalInfo")
                'If Not dr.IsNull("EnemaOther") Then OtherEnemaRadTextBox.Text = dr("EnemaOther")
                BowelPrepQtyRadNumericTextBox.Value = CInt(dr("Quantity"))
                If Not dr.IsNull("leftPrepScore") Then LeftRadNumericTextBox.Value = CInt(dr("leftPrepScore"))
                If Not dr.IsNull("rightPrepScore") Then RightRadNumericTextBox.Value = CInt(dr("rightPrepScore"))
                If Not dr.IsNull("transversePrepScore") Then TransverseRadNumericTextBox.Value = CInt(dr("transversePrepScore"))
                If Not dr.IsNull("TotalPrepScore") Then TotalScoreLabel.Text = CInt(dr("TotalPrepScore"))
            End If
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("There was an error loading bowl prep", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, ref, "There was an error loading your bowel prep data")
            RadNotification1.Show()
        End Try
    End Sub
End Class