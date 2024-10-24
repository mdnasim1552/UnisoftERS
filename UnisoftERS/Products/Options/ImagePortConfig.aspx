<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="ImagePortConfig.aspx.vb" Inherits="UnisoftERS.ImagePortConfig" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Add/Edit ImagePort Devices</title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../Scripts/Global.js"></script>
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <link type="text/css" href="../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
    </style>

</head>
<body>
    <form id="form1" runat="server">
        <!-- FORM All controls in here -->
        <asp:HiddenField ID="hiddenShowSuppressedItems" runat="server" Value="0" />
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator2" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Metro" />
        <telerik:RadNotification ID="FailedNotification" AutoCloseDelay="0" ShowCloseButton="true" runat="server" VisibleOnPageLoad="false" Skin="Metro" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>" ForeColor="Red" Position="Center" />
        <%--OnAjaxRequest="RadAjaxManager1_AjaxRequest"--%>
        <!-- Local Screen presentation -->
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest">
            <AjaxSettings>
                <telerik:AjaxSetting AjaxControlID="RadAjaxManager1">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="ImagePortRadGrid" LoadingPanelID="RadAjaxLoadingPanel1"/>
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="AddNewDeviceSaveRadButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="AddNewDeviceSaveRadButton" UpdatePanelRenderMode="Inline" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="FailedNotification">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="FailedNotification" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="RadWindowManager1">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="ImagePortRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="ImagePortRadGrid">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="ImagePortRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="EditLinkButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="ImagePortRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="AddNewImagePortButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="ImagePortConfigWindow" LoadingPanelID="RadAjaxLoadingPanel1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="LinkPCSaveRadButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="LinkPCSaveRadButton" UpdatePanelRenderMode="Inline" />
                        <telerik:AjaxUpdatedControl ControlID="FailedNotification" />
                        <telerik:AjaxUpdatedControl ControlID="ImagePortRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
        </telerik:RadAjaxManager>

        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro">
        </telerik:RadAjaxLoadingPanel>
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <div>
        </div>

        <div class="optionsHeading">
            <asp:Label ID="HeadingLabel" runat="server" Text="Image Port"></asp:Label>
        </div>

        <div id="HospitalFilterDiv" runat="server" class="optionsBodyText" style="margin: 10px;">
            Operating Hospital:&nbsp;<telerik:RadComboBox ID="OperatingHospitalsRadComboBox" runat="server" Width="270px" AutoPostBack="true" CssClass="filterDDL" />
        </div>

        <div id="FormDiv" runat="server" style="margin-top: 10px;">
            <div style="margin-left: 10px; margin-top: 20px;" class="rptText">
                <telerik:RadGrid ID="ImagePortRadGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false" AllowSorting="true"
                    DataSourceID="ImagePortDataSource" OnItemCommand="ImagePortRadGrid_ItemCommand"
                    Skin="Metro" PageSize="50" AllowPaging="true" Style="margin-bottom: 10px; width: 75%; height: 500px;">
                    <HeaderStyle Font-Bold="true" />
                    <MasterTableView ShowHeadersWhenNoRecords="true" ClientDataKeyNames="OperatingHospitalId,ImagePortId,PortName,IsActive,RoomId,MacAddress,Comments,Static,FriendlyName,Default" DataKeyNames="ImagePortId, PortName,IsActive,RoomId,Static,FriendlyName,Default" TableLayout="Fixed"
                        EnableNoRecordsTemplate="true" CssClass="MasterClass">
                        <Columns>
                            <telerik:GridTemplateColumn UniqueName="EditLinkButtonColumn" HeaderStyle-Width="65px">
                                <ItemTemplate>
                                    <asp:LinkButton ID="EditLinkButton" runat="server" Text="Edit" ToolTip="Edit Image Port" Font-Italic="true"></asp:LinkButton>
                                </ItemTemplate>
                                <HeaderTemplate>
                                    <%--<telerik:RadButton ID="AddNewImagePortButton" runat="server" Text="Add New ImagePort" Skin="Windows7" OnClientClicked=""   AutoPostBack="false" />--%>
                                    <telerik:RadButton ID="AddNewImagePortButton" runat="server" OnClientClicked="EditImagePort" Text="Add New" Skin="Metro" AutoPostBack="false"></telerik:RadButton>
                                </HeaderTemplate>
                            </telerik:GridTemplateColumn>

                            <telerik:GridBoundColumn DataField="PortName" HeaderText="Image Port" SortExpression="PortName" HeaderStyle-Width="100px" AllowSorting="true" ShowSortIcon="true" />
                            <telerik:GridBoundColumn DataField="RoomName" HeaderText="Room Name" SortExpression="RoomName" HeaderStyle-Width="100px" AllowSorting="true" ShowSortIcon="true" />
                            <telerik:GridBoundColumn DataField="FriendlyName" HeaderText="Friendly Name" SortExpression="FriendlyName" HeaderStyle-Width="100px" AllowSorting="true" ShowSortIcon="true" />
                            <%--<telerik:GridTemplateColumn ItemStyle-HorizontalAlign="Center" HeaderText="Static" HeaderStyle-Width="30px" HeaderStyle-HorizontalAlign="Center">
                                <ItemTemplate>
                                    <asp:CheckBox ID="IsStaticCheckBox" runat="server" Checked='<%#Eval("Static")%>' Enabled="false" />
                                </ItemTemplate>

                            </telerik:GridTemplateColumn>--%>
                            <telerik:GridTemplateColumn UniqueName="PCLInkButton" ItemStyle-HorizontalAlign="Center" HeaderText="Unlink" HeaderStyle-Width="35px" HeaderStyle-HorizontalAlign="Center" Visible="false" >
                                <ItemTemplate>
                                    <asp:LinkButton ID="LinkUnlinkPCLinkButton" runat="server" ToolTip="Link/Unlink Room" Font-Italic="true"></asp:LinkButton>
                                </ItemTemplate>

                            </telerik:GridTemplateColumn>

                            <telerik:GridTemplateColumn UniqueName="TemplateColumn" HeaderStyle-Width="30px" ItemStyle-HorizontalAlign="Center" HeaderText="Active" HeaderStyle-HorizontalAlign="Center">
                                <ItemTemplate>
                                    <asp:CheckBox ID="IsActiveCheckBox" runat="server" Checked='<%#Eval("IsActive")%>' OnCheckedChanged="IsActiveCheckBox_CheckedChanged" AutoPostBack="true" />
                                </ItemTemplate>
                            </telerik:GridTemplateColumn>
                            <telerik:GridTemplateColumn ItemStyle-HorizontalAlign="Center" HeaderText="Default" HeaderStyle-Width="50px" HeaderStyle-HorizontalAlign="Center">
                                <ItemTemplate>
                                    <asp:CheckBox ID="IsDefaultCheckBox" runat="server" Checked='<%#Eval("Default")%>' Enabled="false" />
                                </ItemTemplate>

                            </telerik:GridTemplateColumn>
                        </Columns>
                        <NoRecordsTemplate>
                            <div style="margin-top: 10px; margin-bottom: 10px; margin-left: 5px;" id="NoRecordsDiv" runat="server">
                                No Image Ports found.
                            </div>
                        </NoRecordsTemplate>
                    </MasterTableView>
                    <PagerStyle Mode="NumericPages"></PagerStyle>

                    <ClientSettings>
                        <Scrolling AllowScroll="true" UseStaticHeaders="true" />
                        <Selecting AllowRowSelect="true" />
                    </ClientSettings>
                </telerik:RadGrid>
            </div>
            <asp:HiddenField ID="ImagePortIdHiddenField" runat="server" />

            <telerik:RadWindowManager ID="RadWindowManager1" runat="server" Skin="Metro" Modal="true" VisibleStatusbar="false">
                <Windows>
                    
                    <telerik:RadWindow ID="LinkPCWindow" runat="server" ReloadOnShow="true" VisibleStatusbar="false" Title="Link Room"
                        KeepInScreenBounds="true" Width="450px" Height="200px">
                        <ContentTemplate>
                            <telerik:RadFormDecorator ID="RadFormDecorator3" runat="server" DecoratedControls="All" DecorationZoneID="LinkPCPopupWindowDiv" Skin="Metro" />
                            <div id="LinkPCPopupWindowDiv">
                                <div class="optionsHeading">
                                    Link&nbsp;<asp:Label ID="Label1" runat="server" Text="Image Port"></asp:Label>
                                </div>
                                <table cellspacing="3" cellpadding="3" style="width: 100%">
                                    <tr>
                                        <td>
                                            <br />
                                            <div class="left">
                                                <div style="float: left;">
                                                    <telerik:RadTextBox ID="PopupLinkedPCNameTextBox" runat="Server" Width="250px" CssClass="pcNameTextBox" />&nbsp;&nbsp;
                                                <asp:CheckBox ID="PopupStaticCheckbox" runat="server" CssClass="staticCheckBox" Text="Static" />
                                                </div>
                                                <div style="float: left;">
                                                    &nbsp;<div style="float: left; padding-top: 3px; padding-left: 15px;"><a href="javascript:LinkThisPc();">Link this Room</a></div>
                                                </div>
                                            </div>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <div id="buttonsdiv" style="height: 10px; padding-top: 16px; text-align: center;">
                                                <telerik:RadButton ID="LinkPCSaveRadButton" runat="server" Text="Add" Skin="WebBlue" ButtonType="SkinnedButton" OnClick="LinkPCSaveRadButton_Click" />
                                                &nbsp;&nbsp;
                                        <telerik:RadButton ID="LinkPCCancelRadButton" runat="server" Text="Cancel" Skin="WebBlue" AutoPostBack="false" OnClientClicked="LinkPCWindowClientClose" ButtonType="SkinnedButton" />
                                            </div>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </ContentTemplate>
                    </telerik:RadWindow>

                    <telerik:RadWindow ID="NewEditOtherWindow" runat="server" Modal="true" ReloadOnShow="true" KeepInScreenBounds="true"
                    Width="500px" Height="500px" Title="Edit Image Port" VisibleStatusbar="false" />
                </Windows>
            </telerik:RadWindowManager>
        </div>
        <asp:SqlDataSource ID="ImagePortDataSource" runat="server"
            SelectCommand="SELECT i.ImagePortId, i.OperatingHospitalId, i.PortName, i.RoomID, r.RoomName, i.FriendlyName, upper(MacAddress) as MacAddress, InstrumentId, ISNULL([Static],0) AS [Static], i.IsActive, i.Comments, ISNULL([Default],0) AS [Default] FROM  ERS_ImagePort i LEFT JOIN ERS_SCH_Rooms r ON i.OperatingHospitalId = r.HospitalId AND i.RoomId = r.RoomId WHERE i.OperatingHospitalId = @OperatingHospitalId ORDER BY i.PortName"
            InsertCommand="INSERT INTO ERS_ImagePort (OperatingHospitalId, [PortName], RoomID, [MacAddress],[IsActive], [Comments],[Static], [FriendlyName], [Default]) VALUES (@OperatingHospitalId, @PortName, @RoomID, upper(@MacAddress), @Active, @Comments, @Static, @FriendlyName, @Default)"
            UpdateCommand="UPDATE [ERS_ImagePort] SET [PortName] = @PortName, RoomID=@RoomID, [MacAddress] = upper(@MacAddress), [Comments] = @Comments, [Static]=@Static, [FriendlyName] = @FriendlyName, [Default] = @Default WHERE (ImagePortId = @ImagePortId)"
            DeleteCommand="DELETE FROM [ERS_ImagePort] WHERE ImagePortId = @ImagePortId">
            <SelectParameters>
                <asp:ControlParameter ControlID="OperatingHospitalsRadComboBox" Name="OperatingHospitalId" PropertyName="SelectedValue" />
            </SelectParameters>
            <DeleteParameters>
                <asp:Parameter Name="ImagePortId" Type="Int32"></asp:Parameter>
            </DeleteParameters>
            <UpdateParameters>
                <asp:Parameter Name="ImagePortId" Type="Int32"></asp:Parameter>
                <asp:Parameter Name="PortName" Type="String"></asp:Parameter>
                <asp:Parameter Name="MacAddress" Type="String"></asp:Parameter>
                <asp:Parameter Name="RoomID" Type="Int32"></asp:Parameter>
                <asp:Parameter Name="Comments" Type="String"></asp:Parameter>
                <asp:Parameter Name="Static" Type="Boolean"></asp:Parameter>
                <asp:Parameter Name="FriendlyName" Type="String"></asp:Parameter>
                <asp:Parameter Name="Default" Type="Boolean"></asp:Parameter>
            </UpdateParameters>
            <InsertParameters>
                <asp:ControlParameter ControlID="OperatingHospitalsRadComboBox" Name="OperatingHospitalId" PropertyName="SelectedValue" />
                <asp:Parameter Name="PortName" Type="String"></asp:Parameter>
                <asp:Parameter Name="MacAddress" Type="String"></asp:Parameter>
                <asp:Parameter Name="RoomID" Type="Int32"></asp:Parameter>
                <asp:Parameter Name="Active" Type="Boolean" DefaultValue="true"></asp:Parameter>
                <asp:Parameter Name="Static" Type="Boolean"></asp:Parameter>
                <asp:Parameter Name="Comments" Type="String"></asp:Parameter>
                <asp:Parameter Name="FriendlyName" Type="String"></asp:Parameter>
                <asp:Parameter Name="Default" Type="Boolean"></asp:Parameter>
            </InsertParameters>
        </asp:SqlDataSource>

        <telerik:RadScriptBlock ID="RadCodeBlock1" runat="server">
            <script type="text/javascript">
                $(document).ready(function () {
                    $('.pcNameTextBox').on('keyup', function () {
                       // toggleStatic();
                    });
                });

                function toggleStatic() {
                    if ($('.pcNameTextBox').val().length > 0)
                        $('.staticCheckBox [type=checkbox]').removeAttr('disabled');
                    else
                        $('.staticCheckBox [type=checkbox]').attr('disabled', 'disabled');
                }

                function EditImagePort(rowIndex) {  
                    if (rowIndex > -1) {
                        var gvID = $find('<%=ImagePortRadGrid.ClientID %>');
                        var masterTableView = gvID.get_masterTableView();
                        var ImagePortDataItems = masterTableView.get_dataItems()[rowIndex];
                        //get the datakeyname
                        var roomId = ImagePortDataItems.getDataKeyValue("RoomId");
                        var imagePortId = ImagePortDataItems.getDataKeyValue("ImagePortId"); 
                        var operatingHospitalId = $find("<%=OperatingHospitalsRadComboBox.ClientID%>").get_value();

                        var url = "<%= ResolveUrl("~/Products/Options/EditImagePortConfig.aspx?otherImagePortId={0}&otherRoomId={1}&otherOperatingHospitalId={2}")%>";
                        url = url.replace("{0}", imagePortId);
                        url = url.replace("{1}", roomId);
                        url = url.replace("{2}", operatingHospitalId);
                        
                    }
                    else {  
                        var operatingHospitalId = $find("<%=OperatingHospitalsRadComboBox.ClientID%>").get_value();
                        
                        var url = "<%= ResolveUrl("~/Products/Options/EditImagePortConfig.aspx?otherOperatingHospitalId={0}")%>";
                        url = url.replace("{0}", operatingHospitalId);
                    }
                var oWnd = $find("<%= NewEditOtherWindow.ClientID %>")
                oWnd._navigateUrl = url
                oWnd.SetSize(500, 335);

                //Add the name of the function to be executed when RadWindow is closed.
                oWnd.show();                         
                }

                function Unlink() {
                    if (confirm("Are you sure you want to unlink this image port?")) {
                        return true;
                    }
                    else {
                        return false;
                    }
                }

                function LinkPc(rowIndex) {
                    var gvID = $find('<%=ImagePortRadGrid.ClientID %>');
                    var masterTableView = gvID.get_masterTableView();
                    var ImagePortDataItems = masterTableView.get_dataItems()[rowIndex];

                    //get the datakeyname
                    var ImagePortId = ImagePortDataItems.getDataKeyValue("ImagePortId");
                    $('#<%=ImagePortIdHiddenField.ClientID%>').val(ImagePortId);

                    $('#<%=PopupLinkedPCNameTextBox .ClientID%>').val('');
                   // toggleStatic();

                    var oWnd = $find("<%= LinkPCWindow.ClientID %>"); //this being the name of the window control

                    if (oWnd != null) {
                        oWnd.set_title("Link PC");
                        oWnd.show();
                    }
                }

                //editImagePort
                //Close a rad window
                <%--function CloseConfigWindow() {
                    var oWnd = $find("<%= ImagePortConfigWindow.ClientID %>");
                    if (oWnd != null)
                        oWnd.close();--%>

                //    var oWnd = GetRadWindow();
                //    oWnd.BrowserWindow.refreshGrid();
                //    oWnd.close();
                //}

                function LinkPCWindowClientClose() {
                    var oWnd = $find("<%= LinkPCWindow.ClientID %>");
                    if (oWnd != null)
                        oWnd.close();
                }

                function refreshGrid(arg) {
                    <%--$find("<%= RadAjaxManager1.ClientID %>").ajaxRequest("Rebind"); --%>               

                    if (!arg) {
                    $find("<%= RadAjaxManager1.ClientID %>").ajaxRequest("Rebind");
                }
                else {
                    $find("<%= RadAjaxManager1.ClientID %>").ajaxRequest("RebindAndNavigate");
                }
            }
            </script>
        </telerik:RadScriptBlock>

    </form>

</body>
</html>
