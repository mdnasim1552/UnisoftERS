Imports System.Globalization
Imports Telerik.Web.UI

Public Class GenderList
    Inherits OptionsBase

    ReadOnly Property OperatingHospitalId As Integer
        Get
            Return HospitalDropDownList.SelectedValue
        End Get
    End Property

    ReadOnly Property HospitalRoomId As Integer
        Get
            Return CInt(RoomsDropdown.SelectedItem.Value)
        End Get
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            If Me.Master IsNot Nothing Then
                Dim leftPane As RadPane = DirectCast(Me.Master.FindControl("radLeftPane"), RadPane)
                Dim MainRadSplitBar As RadSplitBar = DirectCast(Me.Master.FindControl("MainRadSplitBar"), RadSplitBar)

                If leftPane IsNot Nothing Then leftPane.Visible = False
                If MainRadSplitBar IsNot Nothing Then MainRadSplitBar.Visible = False
                HospitalDropDownList.SelectedIndex = HospitalDropDownList.FindItemByValue(CInt(Session("OperatingHospitalId")).ToString()).Index
            End If

            MonthLabel.Text = Now.ToString("MMMM yyyy")
            SelectedMonthHiddenField.Value = Now.Month
            SelectedYearHiddenField.Value = Now.Year
        End If
    End Sub

    Private Sub buildDates()
        Try

            Dim rowIndex = 0
            Dim monthDateStart = CDate("01/" & SelectedMonthHiddenField.Value & "/" & SelectedYearHiddenField.Value)
            Dim monthDateEnd = monthDateStart.AddMonths(1) '.AddDays(-1)
            Dim currDate = monthDateStart

            MonthLabel.Text = monthDateStart.ToString("MMMM yyyy")


            Dim dt As New DataTable
            dt.Columns.Add("RowIndex")
            dt.Columns.Add("RowDate")
            dt.Columns.Add("ListDate")
            dt.Columns.Add("AMDiaryID")
            dt.Columns.Add("AMListName")
            dt.Columns.Add("AMListGender")
            dt.Columns.Add("PMDiaryID")
            dt.Columns.Add("PMListName")
            dt.Columns.Add("PMListGender")
            dt.Columns.Add("EVDiaryID")
            dt.Columns.Add("EVListName")
            dt.Columns.Add("EVListGender")

            Dim da As New DataAccess_Sch
            Dim diaryDT = (From s In da.GetAvailableSlots(monthDateStart, monthDateEnd, OperatingHospitalId).AsEnumerable
                           Where CInt(s("RoomId")) = HospitalRoomId
                           Group By DiaryID = s("DiaryID"), RoomID = s("RoomId"), StartDate = s("DiaryStart"), EndDate = s("End"), RecurrenceRule = s("RecurrenceRule"), SlotType = s("SlotType"), ListName = s("ListName") Into Group
                           Select DiaryID, RoomID, StartDate, EndDate, RecurrenceRule, SlotType, ListName).ToList

            While currDate < monthDateEnd
                Dim dr As DataRow = dt.NewRow
                dr("RowIndex") = rowIndex
                dr("RowDate") = currDate.ToString("ddd dd")

                Dim listGender = ""
                Dim AMListGender = ""
                Dim PMListGender = ""
                Dim EVListGender = ""

                For Each d In diaryDT
                    If currDate.Date < d.StartDate.date Then Continue For
                    Dim listName = d.ListName.ToString()

                    If String.IsNullOrWhiteSpace(d.RecurrenceRule.ToString()) Then
                        'repeat based on recurrence rule
                        If CDate(d.StartDate).Date = currDate.Date Then
                            buildDR(d.DiaryID, d.StartDate, currDate, listName, listGender, dr, AMListGender, PMListGender, EVListGender)
                        End If
                    Else
                        Dim recurrentRule = d.RecurrenceRule.ToString().Substring(d.RecurrenceRule.ToString().IndexOf("RRULE:") + 6)
                        recurrentRule = recurrentRule.Substring(0, recurrentRule.IndexOf(vbCrLf))

                        Dim appointmentRule As RecurrenceRule
                        RecurrenceRule.TryParse(d.RecurrenceRule, appointmentRule)

                        Dim freq = appointmentRule.Pattern.Frequency
                        Dim recDays = appointmentRule.Pattern.DaysOfWeekMask

                        Dim lst = recurrentRule.Split(";")
                        Dim rules As New Dictionary(Of String, String)
                        For Each l In lst
                            If l.Contains("=") Then rules.Add(l.Split("=")(0), l.Split("=")(1))
                        Next

                        Select Case rules("FREQ")
                            Case "DAILY"
                                Dim days = rules("BYDAY").Split(",").ToList()
                                Dim interval = rules("INTERVAL")

                                If days.Contains(currDate.DayOfWeek.ToString().ToUpper().Substring(0, 2)) Then
                                    buildDR(d.DiaryID, d.StartDate, currDate, listName, listGender, dr, AMListGender, PMListGender, EVListGender)
                                End If
                            Case "WEEKLY"
                                Dim days = rules("BYDAY").Split(",").ToList()
                                Dim interval = rules("INTERVAL")

                                If days.Contains(currDate.DayOfWeek.ToString().ToUpper().Substring(0, 2)) Then
                                    buildDR(d.DiaryID, d.StartDate, currDate, listName, listGender, dr, AMListGender, PMListGender, EVListGender)
                                End If
                            Case "MONTHLY"

                                Dim intervalPosition = appointmentRule.Pattern.DayOfMonth ' rules("BYSETPOS")
                                Dim monthDay = appointmentRule.Pattern.DayOfMonth

                                'X weekend day of every month can only be a sunday if X = 1. otherwise will be a Saturday. So removing sunday to save confusion if day check below
                                'If intervalPosition <> 1 And rules("BYDAY") = "SA,SU" Then days.Remove("SU")

                                If monthDay = currDate.Day Then 'days.Contains(currDate.DayOfWeek.ToString().ToUpper().Substring(0, 2)) Then
                                    buildDR(d.DiaryID, d.StartDate, currDate, listName, listGender, dr, AMListGender, PMListGender, EVListGender)
                                End If

                                'interval: 1st, 2nd, 3rd, 4th, last (-1)
                                'interval2: day, weekday, weekend day, sun-sat
                            Case RecurrenceFrequency.Yearly
                                'interval: 1st, 2nd, 3rd, 4th, last
                                'interval 2: day, weekday, weekend day, sun-sat
                                'interval 3: month 
                        End Select
                    End If
                Next

                dr("AMListGender") = AMListGender
                dr("PMListGender") = PMListGender
                dr("EVListGender") = EVListGender

                dt.Rows.Add(dr)
                currDate = currDate.AddDays(1)
                rowIndex += 1
            End While

            GenderListRadGrid.DataSource = dt
            GenderListRadGrid.DataBind()
        Catch ex As Exception

        End Try
    End Sub

    Sub buildDR(ByVal diaryId As Integer, ByVal startDate As DateTime, ByVal currentDate As DateTime, ByVal listName As String,
                ByRef listGender As String, ByRef dr As DataRow, ByRef AMListGender As String, ByRef PMListGender As String, ByRef EVListGender As String)
        'check for exitsting record
        Dim da As New DataAccess_Sch
        Dim existingRecord = da.GetGenderLists(diaryId).Where(Function(x) x.ListDate.Date = currentDate.Date).FirstOrDefault
        If existingRecord IsNot Nothing Then
            If existingRecord.Male And existingRecord.Female Then
                listGender = "B"
            ElseIf existingRecord.Male Or existingRecord.Female Then
                listGender = If(existingRecord.Male, "M", "F")
            End If
        End If

        If CDate(startDate).TimeOfDay < New TimeSpan(12, 0, 0) Then
            dr("ListDate") = currentDate
            dr("AMDiaryID") = CInt(diaryId)
            dr("AMListName") = listName
            If existingRecord IsNot Nothing Then AMListGender = listGender
        End If
        If CDate(startDate).TimeOfDay >= New TimeSpan(12, 0, 0) And CDate(startDate).TimeOfDay < New TimeSpan(17, 0, 0) Then
            dr("ListDate") = currentDate
            dr("PMDiaryID") = CInt(diaryId)
            dr("PMListName") = listName
            If existingRecord IsNot Nothing Then PMListGender = listGender
        End If
        If CDate(startDate).TimeOfDay >= New TimeSpan(17, 0, 0) Then
            dr("ListDate") = currentDate
            dr("EVDiaryID") = CInt(diaryId)
            dr("EVListName") = listName
            If existingRecord IsNot Nothing Then EVListGender = listGender
        End If
    End Sub

    Protected Sub BackMonthButton_Click(sender As Object, e As EventArgs)
        Dim newMonth = CInt(SelectedMonthHiddenField.Value) - 1
        Dim currentMonth = CInt(SelectedMonthHiddenField.Value)
        Dim currentYear = CInt(SelectedYearHiddenField.Value)
        Dim newDate = New Date(currentYear, currentMonth, 1).AddMonths(-1)

        SelectedMonthHiddenField.Value = newDate.Month.ToString.PadLeft(2, "0")
        SelectedYearHiddenField.Value = newDate.Year

        buildDates()
        GenderListRadGrid.Rebind()

    End Sub

    Protected Sub ForwardMonthButton_Click(sender As Object, e As EventArgs)
        Dim newMonth = CInt(SelectedMonthHiddenField.Value) + 1

        Dim currentMonth = CInt(SelectedMonthHiddenField.Value)
        Dim currentYear = CInt(SelectedYearHiddenField.Value)
        Dim newDate = DateAdd(DateInterval.Month, 1, New Date(currentYear, currentMonth, 1))

        SelectedMonthHiddenField.Value = newDate.Month.ToString.PadLeft(2, "0")
        SelectedYearHiddenField.Value = newDate.Year


        buildDates()
    End Sub

#Region "Hospital Room Filter"
    Protected Sub HospitalDropDownList_Loaded(sender As Object, e As EventArgs) Handles HospitalDropDownList.SelectedIndexChanged
        HospitalRoomsDataSource.SelectParameters("HospitalID").DefaultValue = HospitalDropDownList.SelectedValue
    End Sub

    Protected Sub SelectRoomButton_Click(sender As Object, e As EventArgs)
        buildDates()
    End Sub

    Protected Sub GenderListRadGrid_ItemDataBound(sender As Object, e As GridItemEventArgs)
        Try

            If e.Item.DataItem IsNot Nothing Then
                Dim AMLabel = CType(e.Item.FindControl("AMListNameLabel"), Label)
                Dim AMGenderCheckboxList = CType(e.Item.FindControl("AMCheckboxList"), CheckBoxList)
                If AMLabel IsNot Nothing AndAlso Not String.IsNullOrWhiteSpace(AMLabel.Text) Then
                    AMGenderCheckboxList.Visible = True
                    Dim gender = DirectCast(e.Item.DataItem, System.Data.DataRowView).Row("AMListGender")
                    If Not String.IsNullOrWhiteSpace(gender) Then
                        If gender = "B" Then
                            AMGenderCheckboxList.Items(0).Selected = True
                            AMGenderCheckboxList.Items(1).Selected = True
                        Else
                            AMGenderCheckboxList.SelectedValue = gender
                        End If
                    End If
                End If

                Dim PMLabel = CType(e.Item.FindControl("PMListNameLabel"), Label)
                Dim PMGenderCheckboxList = CType(e.Item.FindControl("PMCheckboxList"), CheckBoxList)
                If PMLabel IsNot Nothing AndAlso Not String.IsNullOrWhiteSpace(PMLabel.Text) Then
                    PMGenderCheckboxList.Visible = True
                    Dim gender = DirectCast(e.Item.DataItem, System.Data.DataRowView).Row("PMListGender")
                    If Not String.IsNullOrWhiteSpace(gender) Then
                        If gender = "B" Then
                            PMGenderCheckboxList.Items(0).Selected = True
                            PMGenderCheckboxList.Items(1).Selected = True
                        Else
                            PMGenderCheckboxList.SelectedValue = gender
                        End If
                    End If
                End If

                Dim EVLabel = CType(e.Item.FindControl("EVListNameLabel"), Label)
                Dim EVGenderCheckboxList = CType(e.Item.FindControl("EVCheckboxList"), CheckBoxList)
                If EVLabel IsNot Nothing AndAlso Not String.IsNullOrWhiteSpace(EVLabel.Text) Then
                    EVGenderCheckboxList.Visible = True
                    Dim gender = DirectCast(e.Item.DataItem, System.Data.DataRowView).Row("EVListGender")
                    If Not String.IsNullOrWhiteSpace(gender) Then
                        If gender = "B" Then
                            EVGenderCheckboxList.Items(0).Selected = True
                            EVGenderCheckboxList.Items(1).Selected = True
                        Else
                            EVGenderCheckboxList.SelectedValue = gender
                        End If
                    End If
                End If
            End If

        Catch ex As Exception

        End Try
    End Sub

    Sub tmp() Handles Me.PreRenderComplete
        If Not Page.IsPostBack Then
            RoomsDropdown.Items(0).Checked = True
            SelectRoomButton_Click(SelectRoomButton, New EventArgs)
        End If
    End Sub

    Protected Sub RoomsDropdown_PreRender(sender As Object, e As EventArgs)
        'If Not Page.IsPostBack Then
        '    If RoomsDropdown.Items.Count > 0 Then
        '        RoomsDropdown.Items(0).Checked = True
        '        SelectRoomButton_Click(SelectRoomButton, New EventArgs)
        '    End If
        'End If
    End Sub

#End Region
End Class