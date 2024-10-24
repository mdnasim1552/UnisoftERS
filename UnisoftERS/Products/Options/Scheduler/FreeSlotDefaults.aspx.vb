Imports Telerik.Web.UI

Public Class FreeSlotDefaults
    Inherits OptionsBase


    ReadOnly Property OperatingHospitalId As Integer
        Get
            Return HospitalsComboBox.SelectedValue
        End Get
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{HospitalsComboBox, ""}}, DataAdapter.GetOperatingHospitals(), "HospitalName", "OperatingHospitalId")
            populateData()

            If Me.Master IsNot Nothing Then
                Dim leftPane As RadPane = DirectCast(Me.Master.FindControl("radLeftPane"), RadPane)
                Dim MainRadSplitBar As RadSplitBar = DirectCast(Me.Master.FindControl("MainRadSplitBar"), RadSplitBar)

                If leftPane IsNot Nothing Then leftPane.Visible = False
                If MainRadSplitBar IsNot Nothing Then MainRadSplitBar.Visible = False
            End If
        End If

        Dim myAjaxMgr As RadAjaxManager = RadAjaxManager.GetCurrent(Me.Page)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(SaveRadButton, RadNotification1)

    End Sub

    Sub clearData()
        SundayMorningCheckBox.Checked = False
        SundayAfternoonCheckBox.Checked = False
        SundayEveningCheckBox.Checked = False
        SundayCheckBox.Checked = False

        MondayMorningCheckBox.Checked = False
        MondayAfternoonCheckBox.Checked = False
        MondayEveningCheckBox.Checked = False
        MondayCheckBox.Checked = False

        TuesdayCheckBox.Checked = True
        TuesdayMorningCheckBox.Checked = False
        TuesdayAfternoonCheckBox.Checked = False
        TuesdayEveningCheckBox.Checked = False
        TuesdayCheckBox.Checked = False

        WednesdayCheckBox.Checked = True
        WednesdayMorningCheckBox.Checked = False
        WednesdayAfternoonCheckBox.Checked = False
        WednesdayEveningCheckBox.Checked = False
        WednesdayCheckBox.Checked = False

        ThursdayCheckBox.Checked = True
        ThursdayMorningCheckBox.Checked = False
        ThursdayAfternoonCheckBox.Checked = False
        ThursdayEveningCheckBox.Checked = False
        ThursdayCheckBox.Checked = False

        FridayCheckBox.Checked = True
        FridayMorningCheckBox.Checked = False
        FridayAfternoonCheckBox.Checked = False
        FridayEveningCheckBox.Checked = False
        FridayCheckBox.Checked = False

        SaturdayCheckBox.Checked = True
        SaturdayMorningCheckBox.Checked = False
        SaturdayAfternoonCheckBox.Checked = False
        SaturdayEveningCheckBox.Checked = False
        SaturdayCheckBox.Checked = False
    End Sub

    Sub populateData()
        Using db As New ERS.Data.GastroDbEntities
            Dim slotDefaults = (From sd In db.ERS_SCH_FreeSlotDefaults
                                Where sd.OperatingHospitalId = OperatingHospitalId
                                Group sd.AM, sd.PM, sd.EVE By sd.DayOfWeek Into g = Group
                                Select DayOfWeek, DaySession = g.ToList)

            For Each sd In slotDefaults
                Select Case sd.DayOfWeek
                    Case 0
                        SundayMorningCheckBox.Checked = sd.DaySession.Select(Function(x) x.AM).First
                        SundayAfternoonCheckBox.Checked = sd.DaySession.Select(Function(x) x.PM).First
                        SundayEveningCheckBox.Checked = sd.DaySession.Select(Function(x) x.EVE).First
                        SundayCheckBox.Checked = (SundayMorningCheckBox.Checked Or SundayAfternoonCheckBox.Checked Or SundayEveningCheckBox.Checked)

                    Case 1
                        MondayMorningCheckBox.Checked = sd.DaySession.Select(Function(x) x.AM).First
                        MondayAfternoonCheckBox.Checked = sd.DaySession.Select(Function(x) x.PM).First
                        MondayEveningCheckBox.Checked = sd.DaySession.Select(Function(x) x.EVE).First
                        MondayCheckBox.Checked = (MondayMorningCheckBox.Checked Or MondayAfternoonCheckBox.Checked Or MondayEveningCheckBox.Checked)
                    Case 2
                        TuesdayCheckBox.Checked = True
                        TuesdayMorningCheckBox.Checked = sd.DaySession.Select(Function(x) x.AM).First
                        TuesdayAfternoonCheckBox.Checked = sd.DaySession.Select(Function(x) x.PM).First
                        TuesdayEveningCheckBox.Checked = sd.DaySession.Select(Function(x) x.EVE).First
                        TuesdayCheckBox.Checked = (TuesdayMorningCheckBox.Checked Or TuesdayAfternoonCheckBox.Checked Or TuesdayEveningCheckBox.Checked)
                    Case 3
                        WednesdayCheckBox.Checked = True
                        WednesdayMorningCheckBox.Checked = sd.DaySession.Select(Function(x) x.AM).First
                        WednesdayAfternoonCheckBox.Checked = sd.DaySession.Select(Function(x) x.PM).First
                        WednesdayEveningCheckBox.Checked = sd.DaySession.Select(Function(x) x.EVE).First
                        WednesdayCheckBox.Checked = (WednesdayMorningCheckBox.Checked Or WednesdayAfternoonCheckBox.Checked Or WednesdayEveningCheckBox.Checked)
                    Case 4
                        ThursdayCheckBox.Checked = True
                        ThursdayMorningCheckBox.Checked = sd.DaySession.Select(Function(x) x.AM).First
                        ThursdayAfternoonCheckBox.Checked = sd.DaySession.Select(Function(x) x.PM).First
                        ThursdayEveningCheckBox.Checked = sd.DaySession.Select(Function(x) x.EVE).First
                        ThursdayCheckBox.Checked = (ThursdayMorningCheckBox.Checked Or ThursdayAfternoonCheckBox.Checked Or ThursdayEveningCheckBox.Checked)
                    Case 5
                        FridayCheckBox.Checked = True
                        FridayMorningCheckBox.Checked = sd.DaySession.Select(Function(x) x.AM).First
                        FridayAfternoonCheckBox.Checked = sd.DaySession.Select(Function(x) x.PM).First
                        FridayEveningCheckBox.Checked = sd.DaySession.Select(Function(x) x.EVE).First
                        FridayCheckBox.Checked = (FridayMorningCheckBox.Checked Or FridayAfternoonCheckBox.Checked Or FridayEveningCheckBox.Checked)
                    Case 6
                        SaturdayCheckBox.Checked = True
                        SaturdayMorningCheckBox.Checked = sd.DaySession.Select(Function(x) x.AM).First
                        SaturdayAfternoonCheckBox.Checked = sd.DaySession.Select(Function(x) x.PM).First
                        SaturdayEveningCheckBox.Checked = sd.DaySession.Select(Function(x) x.EVE).First
                        SaturdayCheckBox.Checked = (SaturdayMorningCheckBox.Checked Or SaturdayAfternoonCheckBox.Checked Or SaturdayEveningCheckBox.Checked)
                End Select
            Next
        End Using
    End Sub

    Protected Sub SaveSlots(silent As Boolean, operatingHospital As Integer)
        Try
            Using db As New ERS.Data.GastroDbEntities
                db.ERS_SCH_FreeSlotDefaults.RemoveRange(db.ERS_SCH_FreeSlotDefaults.Where(Function(x) x.OperatingHospitalId = operatingHospital))

                Dim entries As New List(Of ERS.Data.ERS_SCH_FreeSlotDefaults)
                If MondayCheckBox.Checked Then
                    entries.Add(New ERS.Data.ERS_SCH_FreeSlotDefaults With {
                        .OperatingHospitalId = operatingHospital,
                        .DayOfWeek = CInt(DayOfWeek.Monday),
                        .AM = MondayMorningCheckBox.Checked,
                        .PM = MondayAfternoonCheckBox.Checked,
                        .EVE = MondayEveningCheckBox.Checked
                    })
                End If

                If TuesdayCheckBox.Checked Then
                    entries.Add(New ERS.Data.ERS_SCH_FreeSlotDefaults With {
                        .OperatingHospitalId = operatingHospital,
                        .DayOfWeek = CInt(DayOfWeek.Tuesday),
                        .AM = TuesdayMorningCheckBox.Checked,
                        .PM = TuesdayAfternoonCheckBox.Checked,
                        .EVE = TuesdayEveningCheckBox.Checked
                    })
                End If

                If WednesdayCheckBox.Checked Then
                    entries.Add(New ERS.Data.ERS_SCH_FreeSlotDefaults With {
                        .OperatingHospitalId = operatingHospital,
                        .DayOfWeek = CInt(DayOfWeek.Wednesday),
                        .AM = WednesdayMorningCheckBox.Checked,
                        .PM = WednesdayAfternoonCheckBox.Checked,
                        .EVE = WednesdayEveningCheckBox.Checked
                    })
                End If

                If ThursdayCheckBox.Checked Then
                    entries.Add(New ERS.Data.ERS_SCH_FreeSlotDefaults With {
                        .OperatingHospitalId = operatingHospital,
                        .DayOfWeek = CInt(DayOfWeek.Thursday),
                        .AM = ThursdayMorningCheckBox.Checked,
                        .PM = ThursdayAfternoonCheckBox.Checked,
                        .EVE = ThursdayEveningCheckBox.Checked
                    })
                End If

                If FridayCheckBox.Checked Then
                    entries.Add(New ERS.Data.ERS_SCH_FreeSlotDefaults With {
                        .OperatingHospitalId = operatingHospital,
                        .DayOfWeek = CInt(DayOfWeek.Friday),
                        .AM = FridayMorningCheckBox.Checked,
                        .PM = FridayAfternoonCheckBox.Checked,
                        .EVE = FridayEveningCheckBox.Checked
                    })
                End If

                If SaturdayCheckBox.Checked Then
                    entries.Add(New ERS.Data.ERS_SCH_FreeSlotDefaults With {
                        .OperatingHospitalId = operatingHospital,
                        .DayOfWeek = CInt(DayOfWeek.Saturday),
                        .AM = SaturdayMorningCheckBox.Checked,
                        .PM = SaturdayAfternoonCheckBox.Checked,
                        .EVE = SaturdayEveningCheckBox.Checked
                    })
                End If

                If SundayCheckBox.Checked Then
                    entries.Add(New ERS.Data.ERS_SCH_FreeSlotDefaults With {
                        .OperatingHospitalId = operatingHospital,
                        .DayOfWeek = CInt(DayOfWeek.Sunday),
                        .AM = SundayMorningCheckBox.Checked,
                        .PM = SundayAfternoonCheckBox.Checked,
                        .EVE = SundayEveningCheckBox.Checked
                    })
                End If

                db.ERS_SCH_FreeSlotDefaults.AddRange(entries)
                db.SaveChanges()
            End Using

            If Not silent Then
                Utilities.SetNotificationStyle(RadNotification1, "Settings saved successfully.")
                RadNotification1.Show()
            End If

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured on set free slots default page.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving your data.")
            RadNotification1.Show()
        End Try

    End Sub

    Protected Sub SaveRadButton_Click(sender As Object, e As EventArgs)
        SaveSlots(False, OperatingHospitalId)
    End Sub

    Protected Sub HospitalsComboBox_SelectedIndexChanged(sender As Object, e As RadComboBoxSelectedIndexChangedEventArgs)
        SaveSlots(True, e.OldValue)
        clearData()
        populateData()
    End Sub
End Class