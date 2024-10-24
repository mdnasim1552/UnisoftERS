Imports Telerik.Web.UI
Imports Telerik.Web.UI.Skins

Public Class UpdateGMCCodes
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            Dim IDsList = Request.QueryString("IDs").ToString().Split(",").ToList()

            Using db As New ERS.Data.GastroDbEntities
                Dim dbSource = (From u In db.ERS_Users
                                Where IDsList.Contains(u.UserID)
                                Select u.UserID, FullName = u.Title & " " & u.Forename & " " & u.Surname, ExistingGMCCode = u.GMCCode).ToList()
                MissingGMCCodesGrid.DataSource = dbSource
                MissingGMCCodesGrid.DataBind()
            End Using
        End If
    End Sub

    Protected Sub SaveGMCCodeButton_Click(sender As Object, e As EventArgs)
        Dim isValid = True
        'save GMC code to DB against 'relevant' userId
        Using db As New ERS.Data.GastroDbEntities
            Try
                Dim codeDuplication = False
                For Each dr As GridDataItem In MissingGMCCodesGrid.Items
                    If dr.ItemType = GridItemType.Item Or dr.ItemType = GridItemType.AlternatingItem Then
                        Dim userId = CInt(dr.GetDataKeyValue("UserId").ToString())
                        Dim gmcCode = CType(dr.FindControl("GMCCodeTextBox"), RadTextBox).Text

                        If String.IsNullOrWhiteSpace(gmcCode) Then
                            CType(dr.FindControl("GMCCodeTextBox"), RadTextBox).CssClass += " validation-error-field"
                            isValid = False
                            Continue For
                        End If

                        If Not String.IsNullOrWhiteSpace(gmcCode) AndAlso Not NedClass.ValidateGMCCode(gmcCode) Then
                            CType(dr.FindControl("GMCCodeTextBox"), RadTextBox).CssClass += " validation-error-field"
                            isValid = False
                            Utilities.SetNotificationStyle(RadNotification1, "Unregistered GMC code. Please provide valid code and try again.", True)
                            RadNotification1.Width = "400"
                            RadNotification1.Show()
                            Continue For
                        End If

                        If db.ERS_Users.Any(Function(x) x.GMCCode = gmcCode) Then
                            CType(dr.FindControl("GMCCodeTextBox"), RadTextBox).CssClass += " validation-error-field"
                            codeDuplication = True
                            isValid = False
                            Continue For
                        Else
                            CType(dr.FindControl("GMCCodeTextBox"), RadTextBox).CssClass.Replace(" validation-error-field", "")
                        End If

                        Dim usr = db.ERS_Users.Where(Function(x) x.UserID = userId).FirstOrDefault
                        usr.GMCCode = gmcCode
                        usr.WhoUpdatedId = CInt(Session("PKUserID"))
                        usr.WhenUpdated=Now
                        db.ERS_Users.Attach(usr)
                        db.Entry(usr).State = Entity.EntityState.Modified
                    End If
                Next

                If Not isValid Then
                    If codeDuplication Then
                        updateGMCValDiv.InnerText = "One or more of your GMC Codes are already being used."
                        UpdateGMCCodeRadNotifier.Show()
                    End If
                Else
                    db.SaveChanges()
                    ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "Create_Procedure", "CloseAndSave();", True)
                End If
            Catch ex As Exception
                Dim errorLogRef As String
                errorLogRef = LogManager.LogManagerInstance.LogError("Error occured on update GMC codes page.", ex)
                Utilities.SetErrorNotificationStyle(UpdateGMCCodeRadNotifier, errorLogRef, "There is a problem saving data.")
                UpdateGMCCodeRadNotifier.Show()
            End Try
        End Using
    End Sub
End Class