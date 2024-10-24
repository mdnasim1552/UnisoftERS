Imports Telerik.Web.UI

Public Class LUTSIPSSSymptomscore
    Inherits ProcedureControls
    Private Shared procType As Integer
    Public sMildText = "(Mildly symptomatic)"
    Public sModeratelyText = "(moderately symptomatic)"
    Public sSeverelyText = "(severely symptomatic)"
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        If Not Page.IsPostBack Then
            procType = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))

            Try
                bindLUTSIPSSSymptom()
            Catch ex As Exception
                Dim ref = LogManager.LogManagerInstance.LogError("There was an error loading LUTS/IPSS Symptoms for binding", ex)
                Utilities.SetErrorNotificationStyle(RadNotification1, ref, "There was a problem loading LUTSIPSS symptom score")
                RadNotification1.Show()
            End Try

        End If
    End Sub

    Private Sub bindLUTSIPSSSymptom()
        Try
            Dim TotalScore As Int16 = 0
            'databing repeater
            Dim dbResult = DataAdapter.LoadLUTSIPSSSymtoms(procType, 1)

            rptSections.DataSource = (From i In dbResult.AsEnumerable
                                      Select SectionId = i("SectionId"), SectionName = i("SectionName") Distinct)
            rptSections.DataBind()



            'load procedure indications
            Dim procedureLUTSIPSSSymptoms = DataAdapter.GetProcedureLUTSIPSSSymptoms(Session(Constants.SESSION_PROCEDURE_ID))
            Dim selectedScoreId
            Dim LUTSIPSSSymptomid
            Dim LUTSIPSSSymptomdataRow
            Dim IPSSScoreList = DataAdapter.LoadIPSSScoreList().DefaultView
            For Each sectionItem As RepeaterItem In rptSections.Items
                Dim rptLUTSIPSSSymptoms As Repeater = sectionItem.FindControl("rptLUTSIPSSSymptoms")
                Dim sectionName = CType(sectionItem.FindControl("SectionNameLabel"), Label).Text

                rptLUTSIPSSSymptoms.DataSource = dbResult.AsEnumerable.Where(Function(x) x("SectionName") = sectionName And x("ParentId") = 0).CopyToDataTable
                rptLUTSIPSSSymptoms.DataBind()

                For Each itm As RepeaterItem In rptLUTSIPSSSymptoms.Items
                    Dim radComboBox As New RadComboBox

                    For Each ctrl As Control In itm.Controls
                        If TypeOf ctrl Is RadComboBox Then

                            radComboBox = CType(ctrl, RadComboBox)
                            radComboBox.Items.Clear()
                            radComboBox.DataTextField = "ScoreValueDescription"
                            radComboBox.DataValueField = "ScoreId"
                            radComboBox.OnClientSelectedIndexChanged = "IPSSScore_changed"
                            radComboBox.Attributes.Add("data-LUTSIPSSScore", "ScoreValue")

                            For Each dataRow As DataRow In IPSSScoreList.ToTable().Rows
                                radComboBox.Items.Add(New RadComboBoxItem(dataRow("ScoreValueDescription"), dataRow("ScoreId")))
                            Next

                            LUTSIPSSSymptomid = CInt(radComboBox.Attributes.Item("data-LUTSIPSSSymptomid"))
                            LUTSIPSSSymptomdataRow = procedureLUTSIPSSSymptoms.AsEnumerable.Where(Function(x As DataRow) x.Field(Of Integer)("LUTSIPSSSymptomid") = LUTSIPSSSymptomid).FirstOrDefault()
                            If Not (LUTSIPSSSymptomdataRow Is Nothing) Then
                                selectedScoreId = Int16.Parse(LUTSIPSSSymptomdataRow("SelectedScoreId").ToString())
                                TotalScore = Int16.Parse(LUTSIPSSSymptomdataRow("TotalScoreValue").ToString())
                                radComboBox.SelectedIndex = radComboBox.Items.FindItemIndexByValue(selectedScoreId)
                                If selectedScoreId > 1 Then
                                    radComboBox.ForeColor = System.Drawing.Color.Red
                                End If
                            End If
                        End If
                    Next


                Next
            Next

            Dim dbResultQuality = DataAdapter.LoadLUTSIPSSSymtoms(procType, 0)

            rptSectionsQuality.DataSource = (From i In dbResultQuality.AsEnumerable
                                             Select SectionId = i("SectionId"), SectionName = i("SectionName") Distinct)
            rptSectionsQuality.DataBind()



            Dim IPSSScoreListQuality = DataAdapter.LoadIPSSScoreListQuality().DefaultView
            For Each sectionItem As RepeaterItem In rptSectionsQuality.Items
                Dim rptLUTSIPSSSymptoms As Repeater = sectionItem.FindControl("rptLUTSIPSSSymptoms")
                Dim sectionName = CType(sectionItem.FindControl("SectionNameLabel"), Label).Text

                rptLUTSIPSSSymptoms.DataSource = dbResultQuality.AsEnumerable.Where(Function(x) x("SectionName") = sectionName And x("ParentId") = 0).CopyToDataTable
                rptLUTSIPSSSymptoms.DataBind()

                For Each itm As RepeaterItem In rptLUTSIPSSSymptoms.Items
                    Dim radComboBox As New RadComboBox

                    For Each ctrl As Control In itm.Controls
                        If TypeOf ctrl Is RadComboBox Then

                            radComboBox = CType(ctrl, RadComboBox)
                            radComboBox.Items.Clear()
                            radComboBox.DataTextField = "ScoreValueDescription"
                            radComboBox.DataValueField = "ScoreId"
                            radComboBox.Attributes.Add("data-LUTSIPSSScore", "ScoreValue")
                            radComboBox.OnClientSelectedIndexChanged = "IPSSScoreQuality_changed"
                            radComboBox.Items.Add(New RadComboBoxItem("Select dropdown", 0))
                            For Each dataRow As DataRow In IPSSScoreListQuality.ToTable().Rows
                                radComboBox.Items.Add(New RadComboBoxItem(dataRow("ScoreValueDescription"), dataRow("ScoreId")))
                            Next

                            LUTSIPSSSymptomid = CInt(radComboBox.Attributes.Item("data-LUTSIPSSSymptomid"))
                            LUTSIPSSSymptomdataRow = procedureLUTSIPSSSymptoms.AsEnumerable.Where(Function(x As DataRow) x.Field(Of Integer)("LUTSIPSSSymptomid") = LUTSIPSSSymptomid).FirstOrDefault()
                            If Not (LUTSIPSSSymptomdataRow Is Nothing) Then
                                selectedScoreId = Int16.Parse(LUTSIPSSSymptomdataRow("SelectedScoreId").ToString())
                                radComboBox.SelectedIndex = radComboBox.Items.FindItemIndexByValue(selectedScoreId)
                            End If
                        End If
                    Next


                Next
            Next


            IPSSTotalScore.Text = TotalScore

        Catch ex As Exception
            Throw ex
        End Try
    End Sub

End Class
