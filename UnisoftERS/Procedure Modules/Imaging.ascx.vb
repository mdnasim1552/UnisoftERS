Imports Telerik.Web.UI

Public Class Imaging
    Inherits ProcedureControls

    Private Shared procType As Integer

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        If Not Page.IsPostBack Then
            procType = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))
            If procType = ProcedureType.ERCP Or procType = ProcedureType.EUS_HPB Then
                bindImaging()
                bindImaging2nd()
            End If
        End If
    End Sub

    Private Sub bindImaging()
        Try
            Dim imagingMethodDT As DataTable = DataAdapter.LoadImagingMethods() 'imagingMethodDT
            Dim filterExpression As String = "Description IN ('Ultrasound', 'CT', 'MRI' ,'MRCP', 'IDA - isotape scan', 'EUS')"
            imagingMethodDT.DefaultView.RowFilter = filterExpression
            imagingMethodDT = imagingMethodDT.DefaultView.ToTable()
            'databing repeater
            rptImagingMethods.DataSource = imagingMethodDT
            rptImagingMethods.DataBind()

            'load procedure imaging methods
            Dim procedureImagingMethod = DataAdapter.GetProcedureImagingMethod(Session(Constants.SESSION_PROCEDURE_ID))

            For Each itm As RepeaterItem In rptImagingMethods.Items
                Dim chk As New CheckBox

                For Each ctrl As Control In itm.Controls
                    If TypeOf ctrl Is CheckBox Then
                        chk = CType(ctrl, CheckBox)
                    End If
                Next

                If chk IsNot Nothing Then
                    Dim uniqueid = CInt(chk.Attributes.Item("data-uniqueid"))

                    chk.Checked = procedureImagingMethod.AsEnumerable.Any(Function(x) CInt(x("UniqueId")) = uniqueid)
                End If
            Next
            If imagingMethodDT.AsEnumerable.Any(Function(x) x("AdditionalInfo")) Then
                rptImagingMethodAdditionalInfo.DataSource = imagingMethodDT.AsEnumerable.Where(Function(x) x("AdditionalInfo")).CopyToDataTable
                rptImagingMethodAdditionalInfo.DataBind()
            End If
            For Each itm As RepeaterItem In rptImagingMethodAdditionalInfo.Items

                Dim tb As New RadTextBox

                For Each ctrl As Control In itm.Controls
                    If TypeOf ctrl Is RadTextBox Then
                        tb = CType(ctrl, RadTextBox)
                    End If
                Next

                If tb IsNot Nothing Then
                    Dim uniqueid = CInt(tb.Attributes.Item("data-uniqueid"))

                    tb.Text = (From si In procedureImagingMethod Where CInt(si("UniqueId")) = uniqueid
                               Select si("AdditionalInformation")).FirstOrDefault
                End If
            Next
        Catch ex As Exception
            Throw ex
        End Try
    End Sub
    Private Sub bindImaging2nd()
        Try
            Dim imagingMethodDT As DataTable = DataAdapter.LoadImagingMethods() 'imagingMethodDT
            Dim filterExpression As String = "Description NOT IN ('Ultrasound', 'CT', 'MRI' ,'MRCP', 'IDA - isotape scan', 'EUS')"
            imagingMethodDT.DefaultView.RowFilter = filterExpression
            imagingMethodDT = imagingMethodDT.DefaultView.ToTable()
            'databing repeater
            rptImagingMethods2nd.DataSource = imagingMethodDT
            rptImagingMethods2nd.DataBind()

            'load procedure imaging methods
            Dim procedureImagingMethod = DataAdapter.GetProcedureImagingMethod(Session(Constants.SESSION_PROCEDURE_ID))

            For Each itm As RepeaterItem In rptImagingMethods2nd.Items
                Dim chk As New CheckBox

                For Each ctrl As Control In itm.Controls
                    If TypeOf ctrl Is CheckBox Then
                        chk = CType(ctrl, CheckBox)
                    End If
                Next

                If chk IsNot Nothing Then
                    Dim uniqueid = CInt(chk.Attributes.Item("data-uniqueid"))

                    chk.Checked = procedureImagingMethod.AsEnumerable.Any(Function(x) CInt(x("UniqueId")) = uniqueid)
                End If
            Next
            If imagingMethodDT.AsEnumerable.Any(Function(x) x("AdditionalInfo")) Then
                rptImagingMethodAdditionalInfo2nd.DataSource = imagingMethodDT.AsEnumerable.Where(Function(x) x("AdditionalInfo")).CopyToDataTable
                rptImagingMethodAdditionalInfo2nd.DataBind()
            End If
            For Each itm As RepeaterItem In rptImagingMethodAdditionalInfo2nd.Items

                Dim tb As New RadTextBox

                For Each ctrl As Control In itm.Controls
                    If TypeOf ctrl Is RadTextBox Then
                        tb = CType(ctrl, RadTextBox)
                    End If
                Next

                If tb IsNot Nothing Then
                    Dim uniqueid = CInt(tb.Attributes.Item("data-uniqueid"))

                    tb.Text = (From si In procedureImagingMethod Where CInt(si("UniqueId")) = uniqueid
                               Select si("AdditionalInformation")).FirstOrDefault
                End If
            Next
        Catch ex As Exception
            Throw ex
        End Try
    End Sub
    Protected Sub rptImagingMethodAdditionalInfo_ItemDataBound(sender As Object, e As RepeaterItemEventArgs)
        If e.Item.DataItem IsNot Nothing Then
            'Other textbox
            If CType(CType(e.Item.DataItem, DataRowView).Row("AdditionalInfo"), Boolean) = True Then
                For Each ctrl As Control In e.Item.Controls
                    If TypeOf ctrl Is WebControl Then
                        'DirectCast(ctrl, WebControl).Attributes.CssStyle.Add("display", "none")
                        DirectCast(ctrl, WebControl).CssClass += " " + Regex.Replace(CType(e.Item.DataItem, DataRowView).Row("Description"), "[^a-zA-Z0-9]", "_") + If(CType(e.Item.DataItem, DataRowView).Row("Description") = "Other", "_imaging ", " ")
                    ElseIf TypeOf ctrl Is HtmlControl Then
                        'DirectCast(ctrl, HtmlControl).Style.Add("display", "none")
                        DirectCast(ctrl, HtmlControl).Attributes("class") += " " + Regex.Replace(CType(e.Item.DataItem, DataRowView).Row("Description"), "[^a-zA-Z0-9]", "_") + If(CType(e.Item.DataItem, DataRowView).Row("Description") = "Other", "_imaging ", " ")
                    End If
                Next

            End If
        End If
    End Sub

    Protected Sub rptImagingMethodAdditionalInfo2nd_ItemDataBound(sender As Object, e As RepeaterItemEventArgs)
        If e.Item.DataItem IsNot Nothing Then
            'Other textbox
            If CType(CType(e.Item.DataItem, DataRowView).Row("AdditionalInfo"), Boolean) = True Then
                For Each ctrl As Control In e.Item.Controls
                    If TypeOf ctrl Is WebControl Then
                        'DirectCast(ctrl, WebControl).Attributes.CssStyle.Add("display", "none")
                        DirectCast(ctrl, WebControl).CssClass += " " + Regex.Replace(CType(e.Item.DataItem, DataRowView).Row("Description"), "[^a-zA-Z0-9]", "_") + If(CType(e.Item.DataItem, DataRowView).Row("Description") = "Other", "_imaging2nd ", " ")
                    ElseIf TypeOf ctrl Is HtmlControl Then
                        'DirectCast(ctrl, HtmlControl).Style.Add("display", "none")
                        DirectCast(ctrl, HtmlControl).Attributes("class") += " " + Regex.Replace(CType(e.Item.DataItem, DataRowView).Row("Description"), "[^a-zA-Z0-9]", "_") + If(CType(e.Item.DataItem, DataRowView).Row("Description") = "Other", "_imaging2nd ", " ")
                    End If
                Next

            End If
        End If
    End Sub
End Class