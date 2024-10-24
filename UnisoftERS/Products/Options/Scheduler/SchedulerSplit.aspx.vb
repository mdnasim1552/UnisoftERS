Imports Telerik.Web.UI

Partial Class Products_Options_Scheduler_SchedulerSplit
    Inherits PageBase
    Private Sub Products_Options_Scheduler_Scheduler_Init(sender As Object, e As EventArgs) Handles Me.Init
        If Not IsPostBack Then AppointmentsObjectDataSource.ConnectionString = DataAccess.ConnectionStr
    End Sub
    Protected Sub Products_Scheduler_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsPostBack Then
            BuildDaysTabStrip(Date.Today)

            'Dim mSch As RadScheduler = DirectCast(MorningScheduler.FindControl("RadScheduler1"), RadScheduler)
            'mSch.DayStartTime = New TimeSpan(8, 0, 0)

            'Dim aSch As RadScheduler = DirectCast(AfternoonScheduler.FindControl("RadScheduler1"), RadScheduler)
            'aSch.DayStartTime = New TimeSpan(13, 0, 0)

            'Dim eSch As RadScheduler = DirectCast(EveningScheduler.FindControl("RadScheduler1"), RadScheduler)
            'eSch.DayStartTime = New TimeSpan(13, 0, 0)

            RefreshCalendars(Date.Today)
        End If
    End Sub

    Private Sub BuildDaysTabStrip(ByVal currentDate As Date)
        'Dim currentDate As Date = CDate("2014-7-21")
        Dim dayIndex As Integer = currentDate.DayOfWeek()
        If dayIndex < DayOfWeek.Monday Then
            dayIndex += 7 'Make monday the first day of week
        End If

        DaysRadTabStrip.Tabs.Clear()

        'DaysRadTabStrip.Tabs.Add(New RadTab("<<"))

        Dim week As New List(Of Date)
        week.Add(currentDate.AddDays(DayOfWeek.Monday - dayIndex))
        week.Add(currentDate.AddDays(DayOfWeek.Tuesday - dayIndex))
        week.Add(currentDate.AddDays(DayOfWeek.Wednesday - dayIndex))
        week.Add(currentDate.AddDays(DayOfWeek.Thursday - dayIndex))
        week.Add(currentDate.AddDays(DayOfWeek.Friday - dayIndex))
        week.Add(currentDate.AddDays(DayOfWeek.Saturday - dayIndex))
        week.Add(currentDate.AddDays(DayOfWeek.Sunday + 7 - dayIndex))

        For Each wkday As Date In week
            DaysRadTabStrip.Tabs.Add(New RadTab(wkday.ToString("ddd, d/MM"), wkday.ToString("yyyy-MM-dd")))
        Next

        'DaysRadTabStrip.Tabs.Add(New RadTab(">>"))

        'DaysRadTabStrip.Tabs(0).Font.Bold = True
        'DaysRadTabStrip.Tabs(DaysRadTabStrip.Tabs.Count - 1).Font.Bold = True

        If currentDate = Date.Today Then
            DaysRadTabStrip.FindTabByValue(Date.Today.ToString("yyyy-MM-dd")).Selected = True
        End If
    End Sub

    Protected Sub DaysRadTabStrip_TabClick(sender As Object, e As RadTabStripEventArgs) Handles DaysRadTabStrip.TabClick
        'If e.Tab.Text = "<<" Then
        '    BuildDaysTabStrip(CDate(DaysRadTabStrip.Tabs(1).Value).AddDays(-1))
        'ElseIf e.Tab.Text = ">>" Then
        '    BuildDaysTabStrip(CDate(DaysRadTabStrip.Tabs(1).Value).AddDays(7))
        'End If
        'RadScheduler1.SelectedDate = CDate(e.Tab.Value)
        'RadScheduler1.DataBind()

        RefreshCalendars(CDate(e.Tab.Value))
    End Sub

    Protected Sub PrevButton_Click(sender As Object, e As EventArgs) Handles PrevButton.Click
        BuildDaysTabStrip(CDate(DaysRadTabStrip.Tabs(0).Value).AddDays(-1))
        RefreshCalendars(CDate(DaysRadTabStrip.SelectedTab.Value))
    End Sub

    Protected Sub NextButton_Click(sender As Object, e As EventArgs) Handles NextButton.Click
        BuildDaysTabStrip(CDate(DaysRadTabStrip.Tabs(0).Value).AddDays(7))
        RefreshCalendars(CDate(DaysRadTabStrip.SelectedTab.Value))
    End Sub

    Protected Sub RadScheduler1_AppointmentCreated(sender As Object, e As AppointmentCreatedEventArgs) Handles RadScheduler1.AppointmentCreated
        If e.Appointment.Duration < New TimeSpan(1, 0, 0) Then
            Dim gogo As HtmlGenericControl = e.Container.FindControl("test")
            e.Container.Controls.Remove(gogo)
        End If
    End Sub

    Protected Sub RadScheduler1_AppointmentDataBound(ByVal sender As Object, ByVal e As SchedulerEventArgs) Handles RadScheduler1.AppointmentDataBound
        e.Appointment.CssClass = "rsCategoryGreen"
    End Sub

    Protected Sub RadScheduler2_AppointmentCreated(sender As Object, e As AppointmentCreatedEventArgs) Handles RadScheduler2.AppointmentCreated
        If e.Appointment.Duration < New TimeSpan(1, 0, 0) Then
            Dim gogo As HtmlGenericControl = e.Container.FindControl("test")
            e.Container.Controls.Remove(gogo)
        End If
    End Sub

    Protected Sub RadScheduler2_AppointmentDataBound(ByVal sender As Object, ByVal e As SchedulerEventArgs) Handles RadScheduler2.AppointmentDataBound
        e.Appointment.CssClass = "rsCategoryOrange"
    End Sub

    Protected Sub RadScheduler3_AppointmentCreated(sender As Object, e As AppointmentCreatedEventArgs) Handles RadScheduler3.AppointmentCreated
        If e.Appointment.Duration < New TimeSpan(1, 0, 0) Then
            Dim gogo As HtmlGenericControl = e.Container.FindControl("test")
            e.Container.Controls.Remove(gogo)
        End If
    End Sub

    Protected Sub RadScheduler3_AppointmentDataBound(ByVal sender As Object, ByVal e As SchedulerEventArgs) Handles RadScheduler3.AppointmentDataBound
        e.Appointment.CssClass = "rsCategoryRed"
    End Sub

    Private Sub RefreshCalendars(ByVal dateChosen As Date)
        RadScheduler1.SelectedDate = dateChosen
        RadScheduler2.SelectedDate = dateChosen
        RadScheduler3.SelectedDate = dateChosen
    End Sub

    Protected Sub ShowTodayTile_Click(sender As Object, e As EventArgs) Handles ShowTodayTile.Click
        If CDate(DaysRadTabStrip.SelectedTab.Value) <> Date.Today Then
            BuildDaysTabStrip(Date.Today)
            RefreshCalendars(Date.Today)
        End If
    End Sub


End Class
