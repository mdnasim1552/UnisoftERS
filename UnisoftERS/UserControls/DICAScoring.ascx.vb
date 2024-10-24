Imports Telerik.Web.UI
Imports Telerik.Web.UI.Editor

Public Class DICAScoring
    Inherits System.Web.UI.UserControl

    Private siteId As Integer
    Public Shared DICAScoreSaved As Boolean

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        siteId = CInt(Request.QueryString("SiteId"))

        If Not Page.IsPostBack Then
            loadDICAScoring()
        End If
    End Sub

    Private Sub loadDICAScoring()
        Try
            Dim da As New DataAccess
            Dim scoreDT = da.LoadDICAScores()

            Dim scoreSections = (From s In scoreDT.AsEnumerable
                                 Where s("ParentId") = 0
                                 Select UniqueId = s("UniqueId"), Description = s("Description") Distinct)


            rptDICAScore.DataSource = scoreSections
            rptDICAScore.DataBind()

            Dim procedureScores = da.GetProcedureDICAScores(siteId)
            If procedureScores.Rows.Count > 0 Then
                Dim dr = procedureScores.Rows(0)
                If CInt(dr("ExtensionId")) > 0 And CInt(dr("GradeId")) > 0 Then
                    DICAScoreSaved = True
                End If
            End If

            For Each itm As RepeaterItem In rptDICAScore.Items
                Dim sectionName = CType(itm.FindControl("lblSectionName"), Label).Text
                Dim parentId = CInt(CType(itm.FindControl("ParentIdHiddenField"), HiddenField).Value)
                Dim ddl As RadComboBox = itm.FindControl("DICAScoreRadComboBox")
                If ddl IsNot Nothing Then
                    Dim sectionScores = scoreDT.AsEnumerable.Where(Function(x) x("ParentId") = parentId)
                    If sectionScores.Count > 0 Then
                        ddl.DataSource = sectionScores.CopyToDataTable()
                        ddl.DataBind()

                        For Each cbitm As RadComboBoxItem In ddl.Items
                            Dim points = sectionScores.Where(Function(x) x("UniqueId") = cbitm.Value).Select(Function(x) x("Points")).FirstOrDefault
                            cbitm.Attributes.Add("data-points", If(points, 0))
                        Next
                    End If

                    If procedureScores.Rows.Count > 0 Then
                        Dim dr = procedureScores.Rows(0)
                        If ddl.Items.FindItemIndexByValue(CInt(dr("ExtensionId"))) > 0 Then
                            ddl.SelectedIndex = ddl.Items.FindItemIndexByValue(CInt(dr("ExtensionId")))
                        ElseIf ddl.Items.FindItemIndexByValue(CInt(dr("GradeId"))) > 0 Then
                            ddl.SelectedIndex = ddl.Items.FindItemIndexByValue(CInt(dr("GradeId")))
                        ElseIf ddl.Items.FindItemIndexByValue(CInt(dr("InflammatorySignsId"))) > 0 Then
                            ddl.SelectedIndex = ddl.Items.FindItemIndexByValue(CInt(dr("InflammatorySignsId")))
                        ElseIf ddl.Items.FindItemIndexByValue(CInt(dr("ComplicationsId"))) > 0 Then
                            ddl.SelectedIndex = ddl.Items.FindItemIndexByValue(CInt(dr("ComplicationsId")))
                        End If
                    End If
                End If
            Next

        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("There was an error loading DICA scores", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, ref, "There was an error loading DICA scores")
            RadNotification1.Show()
        End Try
    End Sub

    Public Function DICAScoring() As Dictionary(Of String, Integer)
        Dim tmp As New Dictionary(Of String, Integer)

        For Each itm As RepeaterItem In rptDICAScore.Items
            Dim parentId = CType(itm.FindControl("ParentIdHiddenField"), HiddenField).Value
            Dim sectionScoring = CType(itm.FindControl("DICAScoreRadComboBox"), RadComboBox).SelectedValue


            tmp.Add(parentId, sectionScoring)
        Next

        Return tmp
    End Function

    Public Function saveScoring() As Boolean
        Try
            Dim scoreResults = DICAScoring()

            If scoreResults("1") > 0 And scoreResults("4") > 0 Then
                Dim da As New DataAccess
                da.saveProcedureDICAScores(siteId, scoreResults("1"), scoreResults("4"), scoreResults("8"), scoreResults("12"))
                DICAScoreSaved = True
                'ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
                Return True
            Else
                DICAScoreSaved = False
                Return False
            End If
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("There was an error loading DICA scores", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, ref, "There was an error loading DICA scores")
            RadNotification1.Show()
            DICAScoreSaved = False
            Return False
        End Try
    End Function
End Class