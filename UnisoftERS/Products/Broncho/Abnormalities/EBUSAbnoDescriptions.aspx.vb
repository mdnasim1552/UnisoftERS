Imports Telerik.Web.UI
Imports System.Data.SqlClient


Partial Class Products_Broncho_Abnormalities_EBUSAbnoDescriptions
    Inherits SiteDetailsBase

    Private siteId As Integer
    Private EBUSAbnoDescId As Integer
    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            SaveButton.Text = If(Request.QueryString("mode") = "edit", "Update", "Save")
            siteId = CInt(Request.QueryString("SiteId"))
            EBUSAbnoDescId = CInt(Request.QueryString("EBUSAbnoDescId"))
            Session("EBUSAbnoDescId") = EBUSAbnoDescId
            SiteIdHiddenField.Value = siteId.ToString()

            Dim reg As String = Request.QueryString("Region")
            'Dim reg As String = SiteDetailsBase.aspx?Region
            SetEBUSAbnoControls()

            Dim dtDu As DataTable = AbnormalitiesDataAdapter.GetAbnormalitiesByAbnoId(EBUSAbnoDescId, "abnormalities_ebus_descriptions_select")
            If dtDu.Rows.Count > 0 Then
                PopulateData(dtDu.Rows(0))
            End If
        End If
    End Sub

    Public Sub SetEBUSAbnoControls()
        Try
            'Dim dsResult As New DataSet

            'Using connection As New SqlConnection(DataAccess.ConnectionStr)
            '    Dim cmd As New SqlCommand("abnormalities_ebus_option_controls_select", connection)
            '    cmd.CommandType = CommandType.StoredProcedure
            '    Dim adapter = New SqlDataAdapter(cmd)

            '    connection.Open()
            '    adapter.Fill(dsResult)
            'End Using

            'Load Biopsy Type

            'Utilities.LoadRadioButtonList(BowelPreparationQualityRadioButtonList, DataAdapter.GetBowelPreparationQuality(), listTextField, listValueField)
            'Utilities.LoadDropdown(New Dictionary(Of RadDropDownList, String)() From {
            '                          {RegimeDropDown, "EBUS Abnormalities Biopsy Type", listTextField, listValueField},
            '                          {NeedleTypeRadDropDownList, "EBUS Abnormalities Biopsy Needle Type", listTextField, listValueField},
            '                          {UnitsRadDropDownList, "EBUS Abnormalities Biopsy Needle Size Units", listTextField, listValueField}
            '                          })

            Utilities.LoadDropdown(New Dictionary(Of RadDropDownList, String)() From {
                                      {RegimeDropDown, "EBUS Abnormalities Biopsy Type"},
                                      {NeedleTypeRadDropDownList, "EBUS Abnormalities Biopsy Needle Type"},
                                      {UnitsRadDropDownList, "EBUS Abnormalities Biopsy Needle Size Units"}
                                      },)

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error in module: Products_Broncho_Abnormalities_EBUS.SetEBUSAbnoControls", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem loading the EBUS controls data.")
            RadNotification1.Show()
        End Try

    End Sub

    Private Sub PopulateData(drDu As DataRow)
        NoneCheckBox.Checked = CBool(drDu("Normal"))

        If CBool(drDu("Normal")) Then Exit Sub

        If Not IsDBNull(drDu("Size")) AndAlso CDbl(drDu("Size")) > 0 Then
            'SizeRadioButtonList.SelectedValue = CInt(drDu("Size"))
            SizeRadNumericTextBox.DbValue = CDbl(drDu("Size"))
        End If

        If Not IsDBNull(drDu("SizeNum")) AndAlso CInt(drDu("SizeNum")) > 0 Then
            SlidingLengthTextBox.DbValue = drDu("SizeNum")
        End If

        If Not IsDBNull(drDu("Shape")) AndAlso CInt(drDu("Shape")) > 0 Then
            ShapeRadioButtonList.SelectedValue = CInt(drDu("Shape"))
        End If

        If Not IsDBNull(drDu("Margin")) AndAlso CInt(drDu("Margin")) > 0 Then
            MarginRadioButtonList.SelectedValue = CInt(drDu("Margin"))
        End If

        If Not IsDBNull(drDu("Echogenecity")) AndAlso CInt(drDu("Echogenecity")) > 0 Then
            EchogenecityRadioButtonList.SelectedValue = CInt(drDu("Echogenecity"))
        End If

        If Not IsDBNull(drDu("CHS")) AndAlso CInt(drDu("CHS")) > 0 Then
            CHSRadioButtonList.SelectedValue = CInt(drDu("CHS"))
        End If

        If Not IsDBNull(drDu("CNS")) AndAlso CInt(drDu("CNS")) > 0 Then
            CNSRadioButtonList.SelectedValue = CInt(drDu("CNS"))
        End If

        If Not IsDBNull(drDu("Vascular")) AndAlso CInt(drDu("Vascular")) > 0 Then
            VascularRadioButtonList.SelectedValue = CInt(drDu("Vascular"))
        End If

        If Not IsDBNull(drDu("NoBxTaken")) AndAlso CInt(drDu("NoBxTaken")) > 0 Then
            NumberTakenRadNumericTextBox.DbValue = drDu("NoBxTaken")
        End If

        If Not IsDBNull(drDu("BxType")) AndAlso CInt(drDu("BxType")) > 0 Then
            RegimeDropDown.SelectedValue = CInt(drDu("BxType"))
        End If

        If Not IsDBNull(drDu("BxNeedleType")) AndAlso CInt(drDu("BxNeedleType")) > 0 Then
            NeedleTypeRadDropDownList.SelectedValue = CInt(drDu("BxNeedleType"))
        End If

        If Not IsDBNull(drDu("BxNeedleSize")) AndAlso CInt(drDu("BxNeedleSize")) > 0 Then
            DiamRadNumericTextBox.DbValue = drDu("BxNeedleSize")
        End If

        If Not IsDBNull(drDu("BxNeedleSizeUnits")) AndAlso CInt(drDu("BxNeedleSizeUnits")) > 0 Then
            UnitsRadDropDownList.SelectedValue = CInt(drDu("BxNeedleSizeUnits"))
        End If

    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        Try
            siteId = CInt(Request.QueryString("SiteId"))
            If siteId <= 0 Then
                siteId = AbnormalitiesDataAdapter.CommitEBUSite(Request.QueryString("Reg"))
            End If

            Session(Constants.SESSION_SITE_ID) = siteId
            If CInt(Session("EBUSAbnoDescId")) <> 0 Then
                AbnormalitiesDataAdapter.SaveEbusAbnosData(
                CInt(Session("EBUSAbnoDescId")),
                siteId,
                NoneCheckBox.Checked,
                Utilities.GetNumericTextBoxValue(SizeRadNumericTextBox),
                Utilities.GetNumericTextBoxValue(SlidingLengthTextBox),
                Utilities.GetRadioValue(ShapeRadioButtonList),
                Utilities.GetRadioValue(MarginRadioButtonList),
                Utilities.GetRadioValue(EchogenecityRadioButtonList),
                Utilities.GetRadioValue(CHSRadioButtonList),
                Utilities.GetRadioValue(CNSRadioButtonList),
                Utilities.GetRadioValue(VascularRadioButtonList),
                Utilities.GetDropDownListValue(RegimeDropDown),
                Utilities.GetNumericTextBoxValue(NumberTakenRadNumericTextBox),
                Utilities.GetDropDownListValue(NeedleTypeRadDropDownList),
                Utilities.GetNumericTextBoxValue(DiamRadNumericTextBox),
                Utilities.GetDropDownListValue(UnitsRadDropDownList))
            Else
                Session("EBUSAbnoDescId") = AbnormalitiesDataAdapter.InsertEbusAbnosData(
                CInt(Session("EBUSAbnoDescId")),
                siteId,
                NoneCheckBox.Checked,
                Utilities.GetNumericTextBoxValue(SizeRadNumericTextBox),
                Utilities.GetNumericTextBoxValue(SlidingLengthTextBox),
                Utilities.GetRadioValue(ShapeRadioButtonList),
                Utilities.GetRadioValue(MarginRadioButtonList),
                Utilities.GetRadioValue(EchogenecityRadioButtonList),
                Utilities.GetRadioValue(CHSRadioButtonList),
                Utilities.GetRadioValue(CNSRadioButtonList),
                Utilities.GetRadioValue(VascularRadioButtonList),
                Utilities.GetDropDownListValue(RegimeDropDown),
                Utilities.GetNumericTextBoxValue(NumberTakenRadNumericTextBox),
                Utilities.GetDropDownListValue(NeedleTypeRadDropDownList),
                Utilities.GetNumericTextBoxValue(DiamRadNumericTextBox),
                Utilities.GetDropDownListValue(UnitsRadDropDownList))
            End If


            Utilities.SetNotificationStyle(RadNotification1)
            RadNotification1.Show()
            ScriptManager.RegisterStartupScript(Me, Me.[GetType](), "CloseMe", "SaveAndClose();", True)
            'ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary(); refreshDiagram(); parent.location.reload();", True)
            'Response.Redirect("~/Products/Broncho/Abnormalities/EBUSAbnormality.aspx?SiteId=" & siteId)
            'ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary(); refreshDiagram();", True)
            'ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "refreshDiagram();", True)
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occurred while saving EBUS Abnormalities.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try

    End Sub

End Class