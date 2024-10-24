Imports System.ComponentModel
Imports System.Web.Script.Serialization
Imports System.Web.Services
Imports DevExpress.CodeParser
Imports DevExpress.XtraRichEdit.API.Layout
Imports DevExpress.XtraRichEdit.Model
Imports Telerik.Web.UI

Public Class PathwayPlanQuestions
    Inherits ProcedureControls

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        loadCancerFollowUpQuestions()
    End Sub

    Private Sub loadCancerFollowUpQuestions()
        Try
            Dim operatingHospital = CInt(Session("OperatingHospitalId"))
            Dim procType As Integer = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))
            Dim dtQuestions = DataAdapter.GetPathwayPlanQuestions(operatingHospital, procType, False)
            FollowUpQuestionsRepeater.DataSource = dtQuestions
            FollowUpQuestionsRepeater.DataBind()

            If dtQuestions IsNot Nothing AndAlso dtQuestions.Rows.Count > 0 Then
                Dim da As New OtherData
                Dim dtQuestionAnswers = da.GetPathwayPlanAnswers(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
                For Each itm As RepeaterItem In FollowUpQuestionsRepeater.Items
                    Dim questionId = CInt(CType(itm.FindControl("QuestionIdHiddenField"), HiddenField).Value)
                    Dim QuestionOptionRadioButton = CType(itm.FindControl("QuestionOptionRadioButton"), RadioButtonList)
                    Dim QuestionAnswerTextBox = CType(itm.FindControl("QuestionAnswerTextBox"), RadTextBox)
                    Dim ComboBoxSelectedItem = CType(itm.FindControl("QuestionOptionComboBox"), RadComboBox)

                    Dim drAnswers = dtQuestionAnswers.AsEnumerable.Where(Function(x) x("QuestionId") = questionId).FirstOrDefault

                    If drAnswers IsNot Nothing AndAlso Not drAnswers.IsNull("OptionAnswer") Then
                        QuestionOptionRadioButton.SelectedValue = drAnswers("OptionAnswer")
                    End If

                    If drAnswers IsNot Nothing AndAlso Not drAnswers.IsNull("FreeTextAnswer") Then
                        QuestionAnswerTextBox.Text = drAnswers("FreeTextAnswer")
                    End If

                    Dim labelText = DirectCast(itm.FindControl("lblQuestion"), RadLabel).Text
                    If labelText = "Evidence of cancer?" Then
                        ComboBoxSelectedItem.Visible = True
                        If drAnswers IsNot Nothing AndAlso Not drAnswers.IsNull("OptionAnswer") Then
                            ComboBoxSelectedItem.DataSource = GetComboBoxItems(drAnswers("OptionAnswer"))
                            ComboBoxSelectedItem.DataBind()
                            ComboBoxSelectedItem.Items.Insert(0, New RadComboBoxItem("", 0))
                            ComboBoxSelectedItem.SelectedValue = drAnswers("EvidenceOfCancer").ToString()
                        Else
                            ComboBoxSelectedItem.Style.Add("display", "none")
                        End If
                    End If
                Next
            End If

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while loading followup questions.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem loading data.")
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub FollowUpQuestionsRepeater_ItemDataBound(sender As Object, e As RepeaterItemEventArgs)
        Try
            If e.Item.DataItem IsNot Nothing Then
                Dim dr = CType(e.Item.DataItem, DataRowView)
                Dim isOptional = CType(dr("Optional"), Boolean)
                Dim freeText = CType(dr("CanFreeText"), Boolean)
                Dim mandatory = CType(dr("Mandatory"), Boolean)
                Dim UnknownOption = CType(dr("UnknownOption"), Boolean)

                If Not isOptional Then
                    CType(e.Item.FindControl("QuestionOptionRadioButton"), RadioButtonList).Visible = False
                Else
                    If UnknownOption Then
                        CType(e.Item.FindControl("QuestionOptionRadioButton"), RadioButtonList).Items.Add(New ListItem() With {.Text = "Unknown", .Value = -1})
                    End If
                End If
                If Not freeText Then
                    CType(e.Item.FindControl("QuestionAnswerTextBox"), RadTextBox).Visible = False
                End If

                CType(e.Item.FindControl("QuestionMandatoryImage"), Image).Visible = mandatory

                Dim combo As RadComboBox = CType(e.Item.FindControl("QuestionOptionComboBox"), RadComboBox)
                Dim questionId As HiddenField = CType(e.Item.FindControl("QuestionIdHiddenField"), HiddenField)
                combo.Attributes("data-questionid") = questionId.Value
            End If
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while loading followup questions.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem loading data.")
            RadNotification1.Show()
        End Try
    End Sub

    Protected Function GetComboBoxItems(optionAnswer As Integer) As DataTable
        Dim dt As New DataTable
        Dim da As New DataAccess
        If optionAnswer = 1 Then
            dt = da.GetList("Evidence of cancer yes")
        ElseIf optionAnswer = 0 Then
            dt = da.GetList("Evidence of cancer no")
        Else
            dt = da.GetList("Evidence of cancer unknown")
        End If
        Return dt
    End Function

End Class