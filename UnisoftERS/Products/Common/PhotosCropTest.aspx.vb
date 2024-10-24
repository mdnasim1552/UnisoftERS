Imports Telerik.Web.UI

Partial Class Products_Common_PhotosCropTest
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(sender As Object, e As System.EventArgs) Handles Me.Load
        'If Not String.IsNullOrEmpty(Request.QueryString("SiteId")) Then
        '    HeaderLabel.Text = "Attach photo(s) to the <b>Anterior</b> site in <b>Upper Body</b> region"
        'Else
        '    HeaderLabel.Text = "Attach photo(s) to the Report"
        '    SiteRadioButton.Text = "Attach to a site"
        '    ProcedureRadioButton.Checked = True
        'End If

        'SiteComboBox.SelectedIndex = 1
    End Sub

    Protected Sub PhotosObjectDataSource_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles PhotosObjectDataSource.Selecting
        'e.InputParameters("userIPAddress") = Page.Request.UserHostAddress
        'e.InputParameters("userHostFullName") = System.Net.Dns.GetHostEntry(Request.ServerVariables("remote_addr")).HostName
        e.InputParameters("userHostName") = Session("RoomName") ' System.Net.Dns.GetHostEntry(Request.ServerVariables("remote_addr")).HostName.Split(".")(0)
    End Sub

End Class
