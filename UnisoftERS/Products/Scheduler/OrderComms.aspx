<%@ Page Language="vb" MasterPageFile="~/Templates/Scheduler.master" AutoEventWireup="false" Inherits="UnisoftERS.OrderComms" CodeBehind="OrderComms.aspx.vb" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContentPlaceHolder" runat="Server">

    <title>Solus Endoscopy : Orders</title>
    <script type="text/javascript" src="../../Scripts/global.js"></script>
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <link type="text/css" href="../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
    </style>
    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <script type="text/javascript">
            $(window).on('load', function () {
            });
            $(document).ready(function () {
            });

            function EditClosed(sender) {

                sender.remove_close(EditClosed);
                //alert('client closed');
                var btn = $find("<%=SearchButton.ClientID %>");
                btn.click();
            }

            function editOrderComm(OrderId) {
              <%'var grid = $find("<%=OrderCommsRadGrid.ClientID").get_masterTableView().get_selectedItems()[0];%>
                if (OrderId > 0) {
                  <%'var id = grid.getDataKeyValue("OrderId");%>
                    var rdwindow = radopen("EditOrderComms.aspx?OrderId=" + OrderId, "Order Details", 1000, 850);
                    rdwindow.set_title('<center>Order Detail</center>');
                    rdwindow.set_visibleStatusbar(false);
                    rdwindow.add_close(EditClosed);
                    return false;
                }
            }

<%--          function setSuppressed() {
              var supbtn = $find("<%= SuppressConsultant.ClientID%>")
                var grid = $find("<%= OrderCommsRadGrid.ClientID%>").get_masterTableView().get_selectedItems()[0]
                if (grid != null) {
                    var id = grid.getDataKeyValue("Suppressed");
                    if (id == 'No') {
                        supbtn.set_text("Suppress Consultant");
                    } else {
                        supbtn.set_text("Unsuppress Consultant");
                    }
                }
            }--%>
            function addOrderComms() {
                var rdwindow = radopen("EditOrderComms.aspx", "Add Order", 850, 750);
                rdwindow.set_title('<center>Add Order</center>');
                rdwindow.set_visibleStatusbar(false);
                rdwindow.add_close(EditClosed);
                return false;
            }
<%--            function ClientClosed() {
                $find("<%=OrderCommsRadGrid.ClientID%>").get_masterTableView().rebind()
                var supbtn = $find("<%= editOrderCommButton.ClientID%>")
                supbtn.set_enabled(false);
                var supbtn = $find("<%= SuppressConsultant.ClientID%>")
                supbtn.set_enabled(false);
            }--%>

            function Show() {
                if (confirm("Are you sure you want to suppress this Order?")) {
                    return true;
                }
                else {
                    return false;
                }
            }



            function refreshGrid(arg) {
                if (!arg) {
                   <%-- $find("<%= RadAjaxManager1.ClientID %>").ajaxRequest("Rebind");--%>
                    window.location.reload();
                }
                else {
                    <%--$find("<%= RadAjaxManager1.ClientID %>").ajaxRequest("RebindAndNavigate");--%>
                }
            }

<%--            function showSuppressedItems(sender, args) {
                document.getElementById('hiddenShowSuppressedItems').value = args.get_checked();
                var masterTable = $find("<%= OrderCommsRadGrid.ClientID%>").get_masterTableView();
                masterTable.rebind();
            }--%>

            <%--function ExportToExcel() {

                var masterTable = $find("<%=OrderCommsRadGrid.ClientID %>").get_masterTableView();
                masterTable.exportToExcel();
            }--%>
</script>
    </telerik:RadScriptBlock>
</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyContentPlaceHolder" runat="Server">
    <asp:HiddenField ID="hiddenShowSuppressedItems" runat="server" Value="0" />
    <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
    <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />

    <%--<telerik:RadAjaxManager ID="RadAjaxManager2" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest">--%>
    <ajaxsettings>
                <telerik:AjaxSetting AjaxControlID="RadWindowManager1">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="OrderCommsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="OrderCommsRadGrid">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="OrderCommsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="HideSuppressButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="FormDiv" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="SuppressedComboBox">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="OrderCommsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="SearchButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="OrderCommsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1"  />
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </ajaxsettings>
    <%--</telerik:RadAjaxManager>--%>

    <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro">
    </telerik:RadAjaxLoadingPanel>

    <div class="optionsHeading">
        <asp:Label ID="HeadingLabel" runat="server" Text="Order : List of patients"></asp:Label>
    </div>

    <telerik:RadFormDecorator runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
    <asp:ObjectDataSource ID="OrderCommsObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="GetOrderCommsList" OnSelecting="OrderCommsObjectDataSource_Selecting">
        <SelectParameters>
            <%--<asp:ControlParameter Name="operatingHospitalId" ControlID="cboOperatingHospitals" PropertyName="SelectedValue" DefaultValue="1" DbType="Int32" />--%>
            <asp:ControlParameter Name="operatingHospitalId" ControlID="cboOperatingHospitals" PropertyName="SelectedValue" DbType="String" />
            <asp:ControlParameter Name="intOrderStatusID" ControlID="cboOrderCommOrderStatus" PropertyName="SelectedValue" DefaultValue="0" DbType="Int32" />
            <asp:ControlParameter Name="intProcedureTypeId" ControlID="cboProcedureType" PropertyName="SelectedValue" DefaultValue="0" DbType="Int32" />
            <asp:ControlParameter Name="intPriorityId" ControlID="cboPriority" PropertyName="SelectedValue" DefaultValue="0" DbType="Int32" />
        </SelectParameters>
    </asp:ObjectDataSource>
    <div id="FormDiv" runat="server" style="margin-top: 10px;">
        <div id="searchBox" runat="server" class="optionsBodyText" style="margin-left: 10px; margin-bottom: -30px">
            <asp:Panel ID="Panel1" runat="server" DefaultButton="SearchButton">
                <table border="0" width="100%">
                    <tr>
                        <td>
                            <table border="0">
                                <tr>
                                    <td style="padding-left: 10px;">Trust :<br />
                                        <telerik:RadComboBox ID="cboTrusts" runat="server" Skin="Windows7" AutoPostBack="true" Font-Bold="false" Width="100%" CssClass="filterDDL"></telerik:RadComboBox>
                                    </td>
                                    <td>&nbsp;</td>
                                    <td>Hospital :<br />
                                        <telerik:RadComboBox ID="cboOperatingHospitals" runat="server"  Skin="Windows7" AutoPostBack="false" Font-Bold="false" Width="100%" CssClass="filterDDL" Filter="StartsWith" CheckBoxes="true"></telerik:RadComboBox>
                                    </td>
                                    <td>&nbsp;</td>
                                    <td></td>
                                    <td>Order Status :<br />
                                        <telerik:RadComboBox ID="cboOrderCommOrderStatus" runat="server" Skin="Windows7" AutoPostBack="false" Font-Bold="false" Width="100%" CssClass="filterDDL" Filter="StartsWith"></telerik:RadComboBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td style="padding-top: 10px; padding-left: 10px;"></td>
                                    <td></td>
                                    <td>Procedure Type :<br />
                                        <telerik:RadComboBox ID="cboProcedureType" runat="server" Skin="Windows7" AutoPostBack="false" Font-Bold="false" Width="100%" CssClass="filterDDL" Filter="StartsWith"></telerik:RadComboBox>
                                    </td>
                                    <td>&nbsp;</td>
                                    <td></td>
                                    <td>Priority :
                                        <br />
                                        <telerik:RadComboBox ID="cboPriority" runat="server" Skin="Windows7" AutoPostBack="false" Font-Bold="false" Width="100%" CssClass="filterDDL" Filter="StartsWith"></telerik:RadComboBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td style="text-align: center; padding-bottom: 5px; padding-top: 10px;" colspan="6">
                                        <telerik:RadButton ID="SearchButton" runat="server" Text="Search" Font-Bold="true" Skin="Office2007" OnClick="SearchButton_Click" />
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td>&nbsp;</td>
                        <td style="vertical-align:middle;">
                            <table border="0"  style="padding:2px 2px 2px 2px;display:table-cell;">
                                <tr>
                                    <td style="vertical-align:middle !important;display:table-cell !important;">
                                        <img src="../../Images/ocsgreen.png" width="21px" />
                                    </td>
                                    <td>: Breach days within 21 days or less</td>
                                </tr>
                                <tr>
                                    <td style="vertical-align:middle;display:table-cell;">
                                        <img src="../../Images/ocsamber.png" width="21px" />
                                    </td>
                                    <td>: Breach days within 14 days or less</td>
                                </tr>
                                <tr>
                                    <td style="vertical-align:middle;display:table-cell;">
                                        <img src="../../Images/ocsred.png" width="21px" />
                                    </td>
                                    <td>: Breach days within 7 days or less</td>
                                </tr>
                                <tr>
                                    <td>&nbsp;</td>
                                    <td style="vertical-align:middle !important;">
                                        : Others - Breach days more than 21 days
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>

            </asp:Panel>
        </div>


        <div style="margin-left: 10px; margin-top: 20px; border: 0px solid;" class="rptText">
            <table border="0" style="width: 100%">
                <tr>
                    <td style="width:80%;">

                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <telerik:RadGrid ID="OrderCommsRadGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false" AllowSorting="true"
                            DataSourceID="OrderCommsObjectDataSource" Skin="Office2007" AllowPaging="false" ClientSettings-Scrolling-AllowScroll="true" Style="margin-bottom: 10px;" ClientSettings-Scrolling-ScrollHeight="450">
                            <HeaderStyle Font-Bold="true" />
                            <ClientSettings EnableRowHoverStyle="true" Scrolling-UseStaticHeaders="true">
                            </ClientSettings>
                            <MasterTableView ShowHeadersWhenNoRecords="true" ClientDataKeyNames="OrderId" DataKeyNames="OrderId" TableLayout="Fixed" EnableNoRecordsTemplate="true" CssClass="MasterClass">
                                <Columns>
                                    <telerik:GridBoundColumn DataField="Alert" HeaderText="Alert" HeaderStyle-Width="40px" AllowSorting="false" ShowSortIcon="false" />
                                    <telerik:GridBoundColumn DataField="BreachDays" HeaderText="Breach<br>Days" HeaderStyle-Width="40px" AllowSorting="false" ShowSortIcon="false" />
                                    <telerik:GridBoundColumn DataField="ProcedureType" HeaderText="Procedure Type" SortExpression="ProcedureType" HeaderStyle-Width="80px" AllowSorting="true" ShowSortIcon="true" />
                                    <telerik:GridBoundColumn DataField="OrderDate" HeaderText="Order Date" SortExpression="OrderDate" HeaderStyle-Width="70px" DataFormatString="{0:dd-MMM-yyyy}" AllowSorting="true" ShowSortIcon="true" />
                                    <telerik:GridBoundColumn DataField="Surname" HeaderText="Surname" SortExpression="Surname" HeaderStyle-Width="80px" AllowSorting="true" ShowSortIcon="true" />
                                    <telerik:GridBoundColumn DataField="Forename" HeaderText="Forename" SortExpression="Forename" HeaderStyle-Width="90px" AllowSorting="true" ShowSortIcon="true" />
                                    <telerik:GridBoundColumn DataField="DateOfBirth" HeaderText="DOB" SortExpression="DateOfBirth" HeaderStyle-Width="70px" DataFormatString="{0:dd-MMM-yyyy}" AllowSorting="true" ShowSortIcon="true" />
                                    <telerik:GridBoundColumn DataField="HospitalNumber" HeaderText="Hospital Number" SortExpression="HospitalNumber" HeaderStyle-Width="70px" ItemStyle-Wrap="true" />
                                    <telerik:GridBoundColumn DataField="NHSNumber" UniqueName="OrderCommsHealthServiceNameColumn" HeaderText="NHS No" SortExpression="NHSNumber" HeaderStyle-Width="60px" />
                                    <telerik:GridBoundColumn DataField="DueDate" HeaderText="Due Date" SortExpression="DueDate" HeaderStyle-Width="70px" DataFormatString="{0:dd-MMM-yyyy}" />
                                    <telerik:GridBoundColumn DataField="Referrer" HeaderText="Referrer" SortExpression="Referrer" HeaderStyle-Width="100px" />
                                    <telerik:GridBoundColumn DataField="TestSite" HeaderText="Site" SortExpression="TestSite" HeaderStyle-Width="70px" />
                                    <telerik:GridBoundColumn DataField="BedLocation" HeaderText="Bed" SortExpression="BedLocation" HeaderStyle-Width="50px" />
                                    <telerik:GridBoundColumn DataField="Priority" HeaderText="Priority" SortExpression="Priority" HeaderStyle-Width="80px" />
                                    <telerik:GridBoundColumn DataField="OrderNumber" HeaderText="Order Number" SortExpression="OrderNumber" HeaderStyle-Width="80px" />
                                    <telerik:GridBoundColumn DataField="OrderSource" HeaderText="Order Source" SortExpression="OrderSource" HeaderStyle-Width="60px" />
                                    <telerik:GridBoundColumn DataField="Status" HeaderText="Status" SortExpression="Status" HeaderStyle-Width="70px" />
                                    <telerik:GridBoundColumn DataField="HospitalName" HeaderText="Hospital Name" SortExpression="HospitalName" HeaderStyle-Width="80px" />
                                    <telerik:GridTemplateColumn UniqueName="TemplateColumn" HeaderStyle-Width="40px" HeaderText="Edit" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                                        <ItemTemplate>
                                            <asp:ImageButton ID="btnViewDetail" runat="server" ImageUrl="~/Images/edit.png" CommandName="ViewDetailOrderComm" ToolTip="Edit"
                                                Height="20px" Width="20px" />
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                </Columns>
                                <NoRecordsTemplate>
                                    <div style="margin-top: 10px; margin-bottom: 10px; margin-left: 5px;" id="NoRecordsDiv" runat="server">
                                        No Orders found.
                                    </div>
                                </NoRecordsTemplate>
                            </MasterTableView>
                            <%--<PagerStyle Mode="NextPrev" PagerTextFormat="Navigate Pages {4} Page {0} of {1}; consultants {2} to {3} of {5}" AlwaysVisible="true" CssClass="gridNavigation" />
                    <ClientSettings>
                        <Scrolling AllowScroll="true"  UseStaticHeaders="true" />
                    </ClientSettings>--%>
                        </telerik:RadGrid>
                    </td>
                </tr>
            </table>
            
        </div>
        <telerik:RadWindowManager ID="RadWindowManager1" runat="server" Skin="Metro" Modal="true" VisibleStatusbar="false">
            <Windows>
            </Windows>
        </telerik:RadWindowManager>
    </div>
</asp:Content>
