Public Class LockList
    Inherits PageBase

    Protected ReadOnly Property DiaryId As Integer
        Get
            If Not String.IsNullOrWhiteSpace(Request.QueryString("diaryId")) Then
                Return CInt(Request.QueryString("diaryId"))
            Else
                Return 0
            End If
        End Get
    End Property

    Protected ReadOnly Property ListSlotId As Integer
        Get
            If Not String.IsNullOrWhiteSpace(Request.QueryString("listSlotId")) Then
                Return CInt(Request.QueryString("listSlotId"))
            Else
                Return 0
            End If
        End Get
    End Property

    Protected ReadOnly Property SlotStart As DateTime
        Get
            Return CDate(Request.QueryString("slotstart"))
        End Get
    End Property

    Protected ReadOnly Property SlotEnd As DateTime
        Get
            Return CDate(Request.QueryString("slotend"))
        End Get
    End Property

    Protected ReadOnly Property DiaryDate As DateTime
        Get
            Return CDate(Request.QueryString("diaryDate"))
        End Get
    End Property

    Protected ReadOnly Property IsLocked As Boolean
        Get
            Return CBool(Request.QueryString("locked"))
        End Get
    End Property

    Protected ReadOnly Property TOD As String
        Get
            Return Request.QueryString("tod")
        End Get
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then

            If DiaryId > 0 Then


                Dim lockReasons = DataAdapter_Sch.GetDiaryLockReasons(True).AsEnumerable.Where(Function(x) CBool(x("IsLockReason")) = (Not IsLocked))

                If IsLocked Then
                    Dim lockedDiaryDetails = DataAdapter_Sch.LockedDiaryDetails(DiaryId)
                    Dim dr = lockedDiaryDetails.Rows(0)
                    LockReasonDiaryDetailsLabel.Text = "List was locked by " & dr("Username") & " on " & CDate(dr("LockedDateTime")).ToShortDateString & " at " & CDate(dr("LockedDateTime")).ToShortTimeString & "<br />" &
                    "Reason: " & dr("LockReason") & "<br />" &
                    "Authorisation: " & dr("LockAuthorizatonText")
                Else
                    LockReasonDiaryDetailsLabel.Text = ""
                End If

                If lockReasons.Count > 0 Then
                    Dim dt = lockReasons.CopyToDataTable()
                    LockReasonRadComboBox.DataSource = dt
                    LockReasonRadComboBox.DataTextField = "Reason"
                    LockReasonRadComboBox.DataValueField = "DiaryLockReasonId"
                    LockReasonRadComboBox.DataBind()
                    LockReasonRadComboBox.Items.Insert(0, "")
                End If

            End If

            If ListSlotId > 0 Then

                Dim lockReasons = DataAdapter_Sch.GetListLockReasons(False).AsEnumerable.Where(Function(x) CBool(x("IsLockReason")) = (Not IsLocked))

                If IsLocked Then
                    Dim lockedListDetails = DataAdapter_Sch.LockedListDetails(ListSlotId)
                    Dim dr = lockedListDetails.Rows(0)
                    LockReasonDiaryDetailsLabel.Text = "List was locked by " & dr("Username") & " on " & CDate(dr("LockedDateTime")).ToShortDateString & " at " & CDate(dr("LockedDateTime")).ToShortTimeString & "<br />" &
                "Reason: " & dr("LockReason") & "<br />" &
                "Comment: " & dr("LockAuthorizatonText")
                Else
                    LockReasonDiaryDetailsLabel.Text = ""
                End If

                If lockReasons.Count > 0 Then
                    Dim dt = lockReasons.CopyToDataTable()
                    LockReasonRadComboBox.DataSource = dt
                    LockReasonRadComboBox.DataTextField = "Reason"
                    LockReasonRadComboBox.DataValueField = "ListLockReasonId"
                    LockReasonRadComboBox.DataBind()
                    LockReasonRadComboBox.Items.Insert(0, "")
                End If

            End If
        End If
    End Sub

    Protected Sub SaveListLockReason()
        If LockReasonRadComboBox.SelectedIndex = 0 Or String.IsNullOrWhiteSpace(DiaryLockAuthorisationRadTextBox.Text) Then
            DiaryLockReasonCustomValidator.IsValid = False
            Exit Sub
        End If

        Try
            Dim lockReason = DiaryLockAuthorisationRadTextBox.Text
            DataAdapter_Sch.lockListSlot(ListSlotId, (Not IsLocked), LockReasonRadComboBox.SelectedValue, lockReason, SlotStart, SlotEnd)

            ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "close-diary-reason", "CloseAndRebind();", True)
        Catch ex As Exception
            Dim errorMsg = "There was a problem locking diary"
            Dim errorRef = LogManager.LogManagerInstance.LogError(errorMsg & " ID " & DiaryId, ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorRef, errorMsg)
            RadNotification1.Show()
        End Try
    End Sub

    Private Sub saveDiaryLockReason()
        Try
            Dim lockReason = DiaryLockAuthorisationRadTextBox.Text
            DataAdapter_Sch.lockDiaryList(DiaryId, (Not IsLocked), LockReasonRadComboBox.SelectedValue, lockReason)

            ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "close-diary-reason", "CloseAndRebind();", True)
        Catch ex As Exception
            Dim errorMsg = "There was a problem locking diary"
            Dim errorRef = LogManager.LogManagerInstance.LogError(errorMsg & " ID " & DiaryId, ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorRef, errorMsg)
            RadNotification1.Show()
        End Try
    End Sub
    Protected Sub SaveLockReasonButton_Click(sender As Object, e As EventArgs)
        If LockReasonRadComboBox.SelectedIndex = 0 Or String.IsNullOrWhiteSpace(DiaryLockAuthorisationRadTextBox.Text) Then
            DiaryLockReasonCustomValidator.IsValid = False
            Exit Sub
        End If

        If DiaryId > 0 Then
            saveDiaryLockReason()
        ElseIf ListSlotId > 0 Then
            SaveListLockReason()
        End If
    End Sub
End Class