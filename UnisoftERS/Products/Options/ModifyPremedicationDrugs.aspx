<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Options_ModifyPremedicationDrugs" CodeBehind="ModifyPremedicationDrugs.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../Scripts/Global.js"></script>
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <link type="text/css" href="../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
        
    </style>

    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <script type="text/javascript">
            $(document).ready(function () {
                var prodId = getParameterByName('option');
                if (prodId == '0') {
                    //$("#<%= DrugTypeRadComboBox.ClientID%>").set_value("0");
                    $("#<%= DrugTypeRadComboBox.ClientID%>").prop("disabled", true);

                } else if (prodId == '1') {
                    //$("#<%= DrugTypeRadComboBox.ClientID%>").set_value("1");
                    $("#<%= DrugTypeRadComboBox.ClientID%>").prop("disabled", true);
                }
            });
            function refreshGrid(arg) {
                if (!arg) {
                    $find("<%= RadAjaxManager1.ClientID %>").ajaxRequest("Rebind");
                }
                else {
                    $find("<%= RadAjaxManager1.ClientID %>").ajaxRequest("RebindAndNavigate");
                }
            }
            function getParameterByName(name) {
                name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
                var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
                    results = regex.exec(location.search);
                return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
            }
            function ShowEditForm(id, rowIndex) {
                var grid = $find("<%= DrugsRadGrid.ClientID%>");

                var rowControl = grid.get_masterTableView().get_dataItems()[rowIndex].get_element();
                grid.get_masterTableView().selectItem(rowControl, true);
                var box = $find("<%= DrugTypeRadComboBox.ClientID%>");
                var type = box.get_value();
                radopen("EditDrugs.aspx?DrugID=" + id + "&DrugType=" + type, "DrugListDialog", 630, 530);
                return false;
            }
            function ShowInsertForm() {
                var box = $find("<%= DrugTypeRadComboBox.ClientID%>");
                var type = box.get_value();
                radopen("EditDrugs.aspx?DrugType=" + type, "DrugListDialog", 640, 530);
                return false;
            }

            function CloseWindow() {
                GetRadWindow().close();
            }

            function GetRadWindow() {
                var oWindow = null;
                if (window.radWindow) oWindow = window.radWindow; //Will work in Moz in all cases, including clasic dialog
                else if (window.frameElement.radWindow) oWindow = window.frameElement.radWindow; //IE (and Moz as well)

                return oWindow;
            }


        </script>
    </telerik:RadScriptBlock>
</head>

<body>
    <script type="text/javascript">
</script>
    <form id="form1" runat="server">
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Metro" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />

        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest">
            <AjaxSettings>

                <telerik:AjaxSetting AjaxControlID="RadAjaxManager1">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="DrugsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="DrugsRadGrid">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="DrugsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="FilterByComboBox">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="DrugsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="DrugTypeRadComboBox">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="DrugsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
        </telerik:RadAjaxManager>


        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro">
        </telerik:RadAjaxLoadingPanel>

        <div class="optionsHeading">Add or Modify Drug</div>

        <telerik:RadFormDecorator ID="ModifyPremedicationDrugsRadFormDecorator" runat="server" DecoratedControls="All"
            DecorationZoneID="FormDiv" Skin="Metro" />
        <%--<telerik:RadAjaxPanel ID="RadAjaxPanel1" runat="server">--%>
        <asp:ObjectDataSource ID="DrugsObjectDataSource" runat="server" SelectMethod="GetPremedicationDrugs" TypeName="UnisoftERS.DataAccess">
            <SelectParameters>
                <asp:ControlParameter ControlID="DrugTypeRadComboBox" Name="ops" PropertyName="SelectedValue" Type="Int32" />
                <%-- <asp:Parameter DefaultValue="true" Name="ops" Type="Boolean" />--%>
            </SelectParameters>
        </asp:ObjectDataSource>

        <div id="FormDiv" runat="server">
            <div style="margin-top: 15px; margin-left: 15px;" class="optionsBodyText">
                <div style="margin-top: 15px;">

                    <table>
                        <tr>
                            <td>Select drug type:
                                <telerik:RadComboBox ID="DrugTypeRadComboBox" runat="server" AutoPostBack="true" CssClass="filterDDL">
                                    <Items>
                                        <telerik:RadComboBoxItem Text="Premedication drugs" Value="0" Selected="true" />
                                        <telerik:RadComboBoxItem Text="Rx (Treatment drugs)" Value="1" />
                                    </Items>
                                </telerik:RadComboBox>

                            </td>
                        </tr>
                        <tr>
                            <td>&nbsp;</td>
                        </tr>
                        <tr>
                            <td>
                                <telerik:RadGrid ID="DrugsRadGrid" runat="server"
                                    DataSourceID="DrugsObjectDataSource" AllowPaging="True" AllowSorting="True" Skin="Metro" Width="700px" GroupPanelPosition="Top" AutoGenerateColumns="False" PageSize="12">
                                    <HeaderStyle Font-Bold="true" Height="25" />
                                    <MasterTableView ShowHeadersWhenNoRecords="true" ClientDataKeyNames="DrugNo">

                                        <Columns>
                                            <telerik:GridTemplateColumn UniqueName="TemplateColumn">
                                                <ItemTemplate>
                                                    <asp:LinkButton ID="EditLinkButton" runat="server" Text="Edit" ToolTip="Edit this user" Font-Italic="true" Width="40px"></asp:LinkButton>
                                                </ItemTemplate>
                                                <HeaderTemplate>
                                                    <telerik:RadButton ID="AddNewDrugButton" runat="server" Text="Add New Drug" Skin="Metro" OnClientClicked="ShowInsertForm" AutoPostBack="false" />
                                                </HeaderTemplate>
                                            </telerik:GridTemplateColumn>
                                            <telerik:GridBoundColumn UniqueName="Name" DataField="Name" HeaderText="Name" SortExpression="Name" HeaderStyle-Width="320px"></telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="Unit" HeaderText="Unit" SortExpression="Unit" HeaderStyle-Width="200px"></telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="Delivery " HeaderText="Delivery method" SortExpression="Delivery" HeaderStyle-Width="200px"></telerik:GridBoundColumn>
                                        </Columns>
                                        <NoRecordsTemplate>
                                            <div style="margin-left: 5px;">No records found</div>
                                        </NoRecordsTemplate>
                                    </MasterTableView>
                                    <ItemStyle Height="30" />
                                    <AlternatingItemStyle Height="30" />
                                    <PagerStyle Mode="NumericPages"></PagerStyle>
                                </telerik:RadGrid>
                            </td>
                        </tr>
                    </table>
                    <%--<div style="height: 10px; margin-left: 10px; padding-top: 2px; padding-bottom: 2px">
                        <telerik:RadButton ID="cmdAccept" runat="server" Text="Close" Skin="Web20" Icon-PrimaryIconCssClass="telerikSaveButton" OnClientClicked="CloseWindow" AutoPostBack="false" />
                    </div>--%>
                </div>

                <telerik:RadWindowManager ID="RadWindowManager1" runat="server" Skin="Metro">
                    <Windows>
                        <telerik:RadWindow ID="DrugListDialog" runat="server" Title="Editing record"
                            Width="800px" Height="500px" Left="150px" ReloadOnShow="true" ShowContentDuringLoad="false"
                            Modal="true" VisibleStatusbar="false" Skin="Metro" Behaviors="Close">
                        </telerik:RadWindow>
                    </Windows>
                </telerik:RadWindowManager>
            </div>
        </div>
    </form>
</body>
</html>
