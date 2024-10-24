Imports Azure.Storage
Imports Telerik.Web.UI

Public Class ScopesAndGuides
    Inherits ProcedureControls

    Public Event ScopeChanged()

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender

        If Not Page.IsPostBack Then
            loadInstruments()
            loadScopeComboxes()
            Select Case Session(Constants.SESSION_PROCEDURE_TYPE)
                Case ProcedureType.Colonoscopy, ProcedureType.Sigmoidscopy
                    trScopeGuide.Visible = True
                Case ProcedureType.Flexi
                    Scope2Section.Visible = False
                    DistalAttachmentSection.Visible = False
                Case ProcedureType.Bronchoscopy, ProcedureType.EBUS
                    DistalAttachmentSection.Visible = False
                    AccessMethodSection.Visible = True
                    Scope2Section.Visible = False
                    TechniqueUsedSection.Visible = True
                Case ProcedureType.Proctoscopy 'Added by rony tfs-4358
                    DistalAttachmentSection.Visible = False
                Case ProcedureType.Transnasal
                    AccessMethodSection.Visible = True
            End Select

        End If

    End Sub

    Private Sub loadInstruments()
        Try
            Dim dtScopeLst As DataTable = DataAdapter.GetScopeLst(CInt(Session(Constants.SESSION_PROCEDURE_TYPE)))
            cboInstrument1.DataSource = dtScopeLst
            cboInstrument1.DataBind()
            cboInstrument1.Items.Insert(0, New RadComboBoxItem("", 0))
            If Not (Session(Constants.SESSION_PROCEDURE_TYPE) = ProcedureType.Flexi) Then
                cboInstrument2.DataSource = dtScopeLst
                cboInstrument2.DataBind()
                cboInstrument2.Items.Insert(0, New RadComboBoxItem("", 0))

                DistalAttachmentRadComboBox.DataSource = DataAdapter.LoadDistalAttachments()
                DistalAttachmentRadComboBox.DataBind()
            End If
            DistalAttachmentRadComboBox.DataSource = DataAdapter.LoadDistalAttachments()
            DistalAttachmentRadComboBox.DataBind()
            'markSectionSelected("Distal attachments", Session(Constants.SESSION_PROCEDURE_ID))

            If (Session(Constants.SESSION_PROCEDURE_TYPE) = ProcedureType.Bronchoscopy) Or (Session(Constants.SESSION_PROCEDURE_TYPE) = ProcedureType.EBUS) Then
                Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{AccessMethodComboBox, "AccessMethod Thoracic"}})
            ElseIf (Session(Constants.SESSION_PROCEDURE_TYPE) = ProcedureType.Transnasal) Then
                Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{AccessMethodComboBox, ""}}, DataAdapter.GetTransnasalAccessMethodThoracicList(), "ListItemText", "ListItemNo")
            End If
            Dim dt As DataTable = DataAdapter.LoadProcedureInstruments(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
            If dt.Rows.Count > 0 Then
                Dim dr = dt.Rows(0)
                cboInstrument1.SelectedValue = CInt(dr("Instrument1"))
                If Not (Session(Constants.SESSION_PROCEDURE_TYPE) = ProcedureType.Flexi) Then
                    cboInstrument2.SelectedValue = CInt(dr("Instrument2"))
                    If (Session(Constants.SESSION_PROCEDURE_TYPE) = ProcedureType.Bronchoscopy) Or (Session(Constants.SESSION_PROCEDURE_TYPE) = ProcedureType.EBUS) Then
                        AccessMethodComboBox.SelectedValue = CInt(dr("Instrument2"))
                    End If
                    ScopeGuideUsedCheckbox.Checked = CInt(dr("ScopeGuide"))
                    Dim techniqueUsed As String = If(dr("TechniqueUsed"), String.Empty)
                    If (techniqueUsed <> "0") Then
                        Dim techIdx As List(Of String) = techniqueUsed.Split({","c}, StringSplitOptions.RemoveEmptyEntries).ToList()
                        For Each item As RadComboBoxItem In TechniqueUsedComboBox.Items
                            If techIdx.Contains(item.Value.ToString) Then
                                item.Checked = True
                            End If
                        Next
                    End If
                End If
            Else
                markSectionSelected("Distal attachments", Session(Constants.SESSION_PROCEDURE_ID))
            End If
            If Not (Session(Constants.SESSION_PROCEDURE_TYPE) = ProcedureType.Flexi) Then
                Dim procedureDistalAttachment = DataAdapter.LoadProcedureDistalAttachment(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
                If procedureDistalAttachment.Rows.Count > 0 Then
                    Dim dr = procedureDistalAttachment.Rows(0)
                    DistalAttachmentRadComboBox.SelectedIndex = DistalAttachmentRadComboBox.FindItemIndexByValue(CInt(dr("DistalAttachmentId")))

                    If Not String.IsNullOrWhiteSpace(DistalAttachmentRadComboBox.SelectedItem.Text) Then
                        ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "start_up_script_da", "toggleDistalAttachmentRows('" & DistalAttachmentRadComboBox.SelectedItem.Text.ToLower & "');", True)
                    End If
                    If Not dr.IsNull("AdditionalInfo") Then
                        DistalAttachmentOtherRadTextBox.Text = dr("AdditionalInfo").ToString()
                    End If
                End If
            End If



        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("There was an error loading scopes", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, ref, "There was an error loading scopes")
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub loadScopeComboxes()
        ScopeManufacturerComboBox.Items.Clear()
        ScopeManufacturerComboBox.DataSource = DataAdapter.GetScopeManufacturers()
        ScopeManufacturerComboBox.DataBind()
        ScopeManufacturerComboBox.Items.Insert(0, New RadComboBoxItem("", ""))
    End Sub
    Protected Sub cboInstrument_SelectedIndexChanged(sender As Object, e As RadComboBoxSelectedIndexChangedEventArgs)

        RaiseEvent ScopeChanged()
    End Sub
    Protected Sub cboInstrument1_ItemDataBound(ByVal sender As Object, ByVal e As RadComboBoxItemEventArgs) Handles cboInstrument1.ItemDataBound

        Dim dataItem As DataRowView = CType(e.Item.DataItem, DataRowView)
        Dim attributeValue As String = dataItem("ScopeGenerationId").ToString()

        e.Item.Attributes("scope-generation-id") = attributeValue
    End Sub
    Protected Sub cboInstrument2_ItemDataBound(ByVal sender As Object, ByVal e As RadComboBoxItemEventArgs) Handles cboInstrument2.ItemDataBound

        Dim dataItem As DataRowView = CType(e.Item.DataItem, DataRowView)
        Dim attributeValue As String = dataItem("ScopeGenerationId").ToString()

        e.Item.Attributes("scope-generation-id") = attributeValue
    End Sub
    Protected Sub ScopeManufacturerComboBox_SelectedIndexChanged(sender As Object, e As RadComboBoxSelectedIndexChangedEventArgs)
        Try
            If ScopeManufacturerComboBox.SelectedValue <> 0 And ScopeManufacturerComboBox.SelectedValue <> -55 Then
                ScopeGenerationComboBox.Items.Clear()

                Dim manufacturerId As Integer = ScopeManufacturerComboBox.SelectedValue
                If ScopeManufacturerComboBox.SelectedValue <> -99 Then
                    Dim dt = DataAdapter.GetScopeManufacturerGeneration(manufacturerId)
                    ScopeGenerationComboBox.DataSource = dt
                    ScopeGenerationComboBox.DataBind()

                    If dt.Rows.Count > 0 Then 'if binding data has no rows then add new option would've already been added
                        ScopeGenerationComboBox.Items.Insert(0, New RadComboBoxItem(""))
                        ScopeGenerationComboBox.Items.Add(New RadComboBoxItem() With {
                            .Text = "Add new",
                            .Value = -55,
                            .ImageUrl = "~/images/icons/add.png",
                            .CssClass = "comboNewItem"
                            })
                        ScopeGenerationComboBox.Attributes.Add("onchange", "if (typeof AddNewItemPopUp === 'function') { AddNewItemPopUp(" & ScopeGenerationComboBox.ClientID & "); } else { window.parent.AddNewItemPopUp(" & ScopeGenerationComboBox.ClientID & ");" & " }")
                    End If
                End If
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