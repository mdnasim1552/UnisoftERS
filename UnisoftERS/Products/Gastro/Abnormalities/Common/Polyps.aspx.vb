Imports Telerik.Web.UI

Public Class Polyps
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not IsPostBack Then
            LoadPolyps()
        End If
    End Sub

    Private Sub LoadPolyps()
        Dim PDetails As List(Of Polyp)
        'Dim rowQty = CInt(Request.QueryString("PolypQuantity"))
        'Dim dt As New DataTable
        'dt.Columns.Add("Type")
        'dt.Columns.Add("Size")
        'dt.Columns.Add("Excised")
        'dt.Columns.Add("Retrieved")
        'dt.Columns.Add("Successful")
        'dt.Columns.Add("SenttToLabs")
        'dt.Columns.Add("Removal")
        'dt.Columns.Add("RemovalBy")
        'dt.Columns.Add("Probably")
        'dt.Columns.Add("TumourType")
        'dt.Columns.Add("Tattooed")
        'dt.Columns.Add("TattooedUsing")

        'For i As Integer = 0 To rowQty - 1
        'Dim polypType As String = ""
        'Dim polypSize As Integer = 0
        'Dim polypExcised As Boolean = False
        'Dim polypRetrieved As Boolean = False
        'Dim polypSuccessful As Boolean = True
        'Dim PolypSentToLabs As Boolean = False
        'Dim polypRemoval As String = ""
        'Dim polypRemovalBy As String = ""
        'Dim polypProbably As Boolean = False
        'Dim polypTumourType As String = ""
        'Dim polypTattooed As Boolean = False
        'Dim polypTattooedUsing As String = ""

        'check for session and load from there if available
        If Session("PolypDetails") IsNot Nothing AndAlso CType(Session("PolypDetails"), List(Of Polyp)).Count > 0 Then
            PDetails = CType(Session("PolypDetails"), List(Of Polyp))
        Else
            PDetails = New List(Of Polyp)
        End If

        'Dim dr = dt.NewRow()
        'dr("InsertionType") = insertionType
        'dr("InsertionLength") = iInsertionLength
        'dr("Dialation") = iDialation
        'dr("DialatinUnits") = sDialationUnits
        'dt.Rows.Add(dr)
        'Next

        PolypsRepeater.DataSource = PDetails
        PolypsRepeater.DataBind()
    End Sub


    Protected Sub PolypRepeater_ItemDataBound(sender As Object, e As RepeaterItemEventArgs)
        If e.Item.DataItem Is Nothing Then Exit Sub
        Dim btnsentToLabsCheckbox As RadButton = e.Item.FindControl("sentToLabsCheckbox")

        btnsentToLabsCheckbox.Checked = e.Item.DataItem("SenttToLabs")
    End Sub
End Class