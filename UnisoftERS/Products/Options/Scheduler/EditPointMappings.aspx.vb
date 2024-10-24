Public Class EditPointMappings
    Inherits System.Web.UI.Page

    Private _DataAdapter As DataAccess = Nothing

    Protected ReadOnly Property DataAdapter() As DataAccess
        Get
            If _DataAdapter Is Nothing Then
                _DataAdapter = New DataAccess
            End If
            Return _DataAdapter
        End Get
    End Property

    ReadOnly Property OperatingHospitalId As Integer
        Get
            Return CInt(Request.QueryString("operatingHospitalId"))
        End Get
    End Property
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

    End Sub

    Protected Sub AddNewItemSaveRadButton_Click(sender As Object, e As EventArgs)
        Try
            If AddNewItemSaveRadButton.CommandName.ToLower = "savenongimappings" Then
                Using db As New ERS.Data.GastroDbEntities

                    If String.IsNullOrWhiteSpace(PointsMappingIDHiddenField.Value) Then
                        Dim newProcType As Integer = DataAdapter.AddNonGIProcedureType(NonGIProcedureTypeRadTextBox.Text, OperatingHospitalId)

                        Dim dbRecord = New ERS.Data.ERS_SCH_PointMappings
                        With dbRecord
                            .ProceduretypeId = newProcType
                            .Points = Convert.ToDecimal(PointsRadTextBox.Text)
                            .Minutes = MinutesRadTextBox.Text
                            .OperatingHospitalId = OperatingHospitalId
                            .NonGI = 1
                        End With

                        db.ERS_SCH_PointMappings.Add(dbRecord)
                    Else
                        Dim dbRecord = db.ERS_SCH_PointMappings.Where(Function(x) x.PointsMappingId = PointsMappingIDHiddenField.Value).FirstOrDefault

                        With dbRecord
                            .Points = Convert.ToDecimal(PointsRadTextBox.Text)
                            .Minutes = MinutesRadTextBox.Text
                            .OperatingHospitalId = OperatingHospitalId
                        End With

                        db.ERS_SCH_PointMappings.Attach(dbRecord)
                        db.Entry(dbRecord).State = Entity.EntityState.Modified
                    End If


                    db.SaveChanges()
                End Using
            ElseIf AddNewItemSaveRadButton.CommandName.ToLower = "savegimappings" Then
                Using db As New ERS.Data.GastroDbEntities
                    Dim dbRecord = db.ERS_SCH_PointMappings.Where(Function(x) x.PointsMappingId = PointsMappingIDHiddenField.Value).FirstOrDefault
                    With dbRecord
                        .Points = Convert.ToDecimal(PointsRadTextBox.Text)
                        .Minutes = MinutesRadTextBox.Text
                        .OperatingHospitalId = OperatingHospitalId
                    End With

                    db.ERS_SCH_PointMappings.Attach(dbRecord)
                    db.Entry(dbRecord).State = Entity.EntityState.Modified

                    db.SaveChanges()
                End Using
            End If

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured on points mappings page.", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try

        ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "Update_Close", "closeAddItemWindow();", True)
    End Sub
End Class