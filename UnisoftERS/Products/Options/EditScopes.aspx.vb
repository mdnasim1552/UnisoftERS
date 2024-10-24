Imports Telerik.Web.UI

Partial Class Products_Options_EditScopes
    Inherits OptionsBase

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        Dim ScopeId As Integer = 0
        If Not Page.IsPostBack Then
            ScopeId = GetScopeId()
            ScopeManufacturerComboBox.DataSource = DataAdapter.GetScopeManufacturers()
            ScopeManufacturerComboBox.DataBind()

            If ScopeId > 0 Then
                fillEditForm(ScopeId)
            End If
            PopulateHospitalForScopesDropdown(ScopeId)
        End If
    End Sub
    Private Sub PopulateHospitalForScopesDropdown(ScopeId As Integer)
        Dim da As New DataAccess
        Dim dtOHforScopes As New DataTable
        dtOHforScopes = da.GetOperatingHospitalsForScopes(ScopeId, CInt(HttpContext.Current.Session("TrustId")))
        HospitalListBox.DataSource = Nothing
        HospitalListBox.Items.Clear()
        HospitalListBox.DataTextField = "HospitalName"
        HospitalListBox.DataValueField = "OperatingHospitalId"
        HospitalListBox.DataSource = dtOHforScopes
        HospitalListBox.DataBind()
    End Sub

    Private Sub fillEditForm(ScopeId As Integer)
        Try

            Dim db As New DataAccess
            Dim dt As DataRow = db.GetScope(ScopeId).Rows(0)
            ScopeNameTextBox.Text = CStr(dt("ScopeName"))
            'HospitalDropDownList.SelectedValue = CStr(dt("HospitalId"))
            ScopeManufacturerComboBox.SelectedValue = CInt(dt("ManufacturerId"))

            If CInt(dt("ManufacturerId")) > 0 Then
                Dim manufacturerDT = DataAdapter.GetScopeManufacturerGeneration(CInt(dt("ManufacturerId")))
                ScopeGenerationComboBox.DataSource = manufacturerDT
                ScopeGenerationComboBox.DataBind()

                'If manufacturerDT.Rows.Count > 0 Then 'if binding data has no rows then add new option would've already been added
                ScopeGenerationComboBox.Items.Insert(0, New RadComboBoxItem(""))
                ScopeGenerationComboBox.Items.Add(New RadComboBoxItem() With {
                        .Text = "Add new",
                        .Value = -55,
                        .ImageUrl = "~/images/icons/add.png",
                        .CssClass = "comboNewItem"
                        })
                ScopeGenerationComboBox.Attributes.Add("onchange", "if (typeof AddNewItemPopUp === 'function') { AddNewItemPopUp(" & ScopeGenerationComboBox.ClientID & "); } else { window.parent.AddNewItemPopUp(" & ScopeGenerationComboBox.ClientID & ");" & " }")
                'End If
                ScopeGenerationComboBox.SelectedValue = CInt(dt("ScopeGenerationId"))
            End If
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while loading scope data.", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem loading data.")
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub SaveScope()
        Try
            Dim manufacturerId As Integer = ScopeManufacturerComboBox.SelectedValue
            Dim SelectedOperatingHospitalIDList As String = ""

            If manufacturerId = -99 Then
                'save new item
                Dim da As New DataAccess
                Dim newId = da.InsertListItem("Scope manufacturer", ScopeManufacturerComboBox.SelectedItem.Text)
                If newId > 0 Then
                    manufacturerId = newId
                End If
            End If

            If HospitalListBox.CheckedItems.Count > 0 Then
                For Each ohItem As RadListBoxItem In HospitalListBox.Items
                    If ohItem.Checked Then
                        If SelectedOperatingHospitalIDList = "" Then
                            SelectedOperatingHospitalIDList = ohItem.Value.ToString()
                        Else
                            SelectedOperatingHospitalIDList = SelectedOperatingHospitalIDList + "," + ohItem.Value.ToString()
                        End If
                    End If
                Next
            End If

            Dim generationId = ScopeGenerationComboBox.SelectedValue
            If generationId = -99 Then
                'save new item
                Dim da As New DataAccess
                Dim newId = da.addNewScopeGeneration(manufacturerId, ScopeGenerationComboBox.SelectedItem.Text)
                If newId > 0 Then
                    generationId = newId
                End If
            End If

            Dim ScopeId As Integer = GetScopeId()
            Dim sqlStr As String = ""
            Dim sqlProc As String = ""
            Dim checkAllProcedure As Boolean = False
            Dim bOtherInvestigations As Boolean = False


            If ProcedureTypeRadListBox.CheckedItems.Count = ProcedureTypeRadListBox.Items.Count Then
                checkAllProcedure = True
            End If

            For Each item As RadListBoxItem In ProcedureTypeRadListBox.Items
                If item.Checked Then
                    If item.Value = 99 Then
                        bOtherInvestigations = True
                    Else
                        sqlProc = sqlProc & "(@ScopeId, " & item.Value & ", " & CInt(Session("PKUserID")) & ", GETDATE()),"
                    End If
                End If
            Next



            If sqlProc <> "" Then
                If Right(sqlProc, 1) = "," Then
                    sqlProc = Left(sqlProc, sqlProc.Length - 1)
                End If

                sqlProc = " INSERT INTO [dbo].[ERS_ScopeProcedures] (ScopeId, ProcedureTypeId, WhoCreatedId, WhenCreated) VALUES " & sqlProc
            End If

            Dim retVal = DataAdapter.saveScope(ScopeId, ScopeNameTextBox.Text, SelectedOperatingHospitalIDList, generationId, checkAllProcedure)

            If ScopeId > 0 Then
                sqlStr = "DELETE FROM ERS_ScopeProcedures WHERE ScopeId = " & ScopeId & " "
            End If

            sqlStr = "DECLARE @ScopeId int = " & retVal & " " & sqlStr & sqlProc

            Try
                DataAccess.ExecuteSQL(sqlStr, Nothing)
                ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "Update_CloseAndRebind", "CloseAndRebind('saved');", True)
            Catch ex As Exception
                Dim errorLogRef As String
                errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving scopes.", ex)
                Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
                RadNotification1.Show()
            End Try

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving scopes.", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try

    End Sub

    Private Sub ProcedureTypeRadListBox_ItemDataBound(sender As Object, e As RadListBoxItemEventArgs) Handles ProcedureTypeRadListBox.ItemDataBound
        Dim item As RadListBoxItem = CType(e.Item, RadListBoxItem)
        Dim row As DataRowView = CType(item.DataItem, DataRowView)
        If Convert.ToInt32(row("ScopeProcId")) > 0 Then
            item.Checked = True
        End If
    End Sub
    Private Sub HospitalListBox_ItemDataBound(sender As Object, e As RadListBoxItemEventArgs) Handles HospitalListBox.ItemDataBound
        Dim item As RadListBoxItem = CType(e.Item, RadListBoxItem)
        Dim row As DataRowView = CType(item.DataItem, DataRowView)
        If Not IsDBNull(row("ScopeId")) Then
            If Convert.ToInt32(row("ScopeId")) > 0 Then
                item.Checked = True
            Else
                item.Checked = False
            End If
        Else
            item.Checked = False
        End If
    End Sub

    Private Function GetScopeId() As Integer
        Dim ScopeId As Integer = 0
        If Not IsDBNull(Request.QueryString("ScopeId")) AndAlso Request.QueryString("ScopeId") <> "" Then
            ScopeId = CInt(Request.QueryString("ScopeId"))
        End If
        Return ScopeId
    End Function

    Private Sub ScopeProcedureObjectDataSource_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles ScopeProcedureObjectDataSource.Selecting
        e.InputParameters("ScopeId") = GetScopeId()
    End Sub

    Protected Sub ScopeManufacturerComboBox_SelectedIndexChanged(sender As Object, e As RadComboBoxSelectedIndexChangedEventArgs)
        Try
            If ScopeManufacturerComboBox.SelectedValue <> 0 And ScopeManufacturerComboBox.SelectedValue <> -55 Then
                ScopeGenerationComboBox.Items.Clear()

                Dim manufacturerId As Integer = ScopeManufacturerComboBox.SelectedValue
                Dim ScopeManufacturerText As String = e.Text 'Added by rony tfs-4442
                If ScopeManufacturerComboBox.SelectedValue <> -99 Then
                    Dim dt = DataAdapter.GetScopeManufacturerGeneration(manufacturerId)
                    ScopeGenerationComboBox.DataSource = dt
                    ScopeGenerationComboBox.DataBind()
                    ScopeGenerationComboBox.Items.Insert(0, New RadComboBoxItem(""))

                    If dt.Rows.Count > 0 AndAlso ScopeManufacturerText = "Other" Then 'if binding data has no rows then add new option would've already been added(Added by rony tfs-4442)
                        ScopeGenerationComboBox.Items.Add(New RadComboBoxItem() With {
                            .Text = "Add new",
                            .Value = -55,
                            .ImageUrl = "~/images/icons/add.png",
                            .CssClass = "comboNewItem"
                            })
                        ScopeGenerationComboBox.Attributes.Add("onchange", "if (typeof AddNewItemPopUp === 'function') { AddNewItemPopUp(" & ScopeGenerationComboBox.ClientID & "); } else { window.parent.AddNewItemPopUp(" & ScopeGenerationComboBox.ClientID & ");" & " }")
                    End If
                End If
            Else 'Added by rony tfs-4442
                ScopeGenerationComboBox.Items.Clear()
            End If

            If ScopeGenerationComboBox.Items.Count Then
            End If
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("Error getting scope generations list", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, ref, "There was an error getting scopes generations list")
            RadNotification1.Show()
        End Try
    End Sub
End Class
