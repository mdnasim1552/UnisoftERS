<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="NonGIConsultants.aspx.vb" Inherits="UnisoftERS.NonGIConsultants" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">

    <title></title>
    <script type="text/javascript" src="../../../Scripts/Global.js"></script>
    <script type="text/javascript" src="../../../Scripts/jquery-3.6.3.min.js"></script>
    <link type="text/css" href="../../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
    </style>

    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <script type="text/javascript">
            function ShowInsertForm() {
                window.radopen("EditNonGIConsultant.aspx", "ConsultantListDialog", 450, 350);
                return false;
            }

            function ShowEditForm(id, rowIndex) {
                var grid = $find("<%= NonGIConsultantsRadGrid.ClientID%>");

                var rowControl = grid.get_masterTableView().get_dataItems()[rowIndex].get_element();
                grid.get_masterTableView().selectItem(rowControl, true);

                window.radopen("EditNonGIConsultant.aspx?UserID=" + id, "ConsultantListDialog", 450,350);
                return false;
            }

              function refreshGrid(arg) {
                if (!arg) {
                    var masterTable = $find("<%= NonGIConsultantsRadGrid.ClientID %>").get_masterTableView();
                    masterTable.fireCommand("Rebind", arg);
                }
                else {
                    var masterTable = $find("<%= NonGIConsultantsRadGrid.ClientID %>").get_masterTableView();
                    masterTable.fireCommand("RebindAndNavigate", arg);
                }
            }

            function Show() {
                if (confirm("Are you sure you want to suppress this user?")) {
                    return true;
                }
                else {
                    return false;
                }
            }
        </script>
    </telerik:RadScriptBlock>
</head>
<body>
    <form id="form1" runat="server">
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server">
        </telerik:RadAjaxManager>        
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro">
        </telerik:RadAjaxLoadingPanel>
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />

        <div class="optionsHeading">
            <asp:Label ID="HeadingLabel" runat="server" Text="Non-GI Consultants"></asp:Label>
        </div>

        <div id="FormDiv" runat="server" style="margin-top: 10px;">
            <div style="margin-left: 10px; margin-top: 20px;" class="rptText">
                <asp:Panel ID="pnlCancellationReasons" runat="server">
                    <telerik:RadGrid ID="NonGIConsultantsRadGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false" AllowSorting="true"
                        DataSourceID="NonGIConsultantsDataSource"
                        Skin="Metro" PageSize="50" AllowPaging="true" Style="margin-bottom: 10px; width: 75%; height: 500px;"
                        OnItemCreated="NonGIConsultantsRadGrid_ItemCreated"
                        OnItemCommand="NonGIConsultantsRadGrid_ItemCommand">
                        <HeaderStyle Font-Bold="true" />
                        <MasterTableView ShowHeadersWhenNoRecords="true" ClientDataKeyNames="UserId" DataKeyNames="UserId" TableLayout="Fixed"
                            EnableNoRecordsTemplate="true" CssClass="MasterClass">
                            <Columns>
                                <telerik:GridTemplateColumn UniqueName="EditLinkButtonColumn" HeaderStyle-Width="65px">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="EditLinkButton" runat="server" Text="Edit" ToolTip="Edit Consultant" Font-Italic="true"></asp:LinkButton>
                                        &nbsp;&nbsp;
                                        <asp:LinkButton ID="SuppressLinkButton" runat="server" Text="Suppress" ToolTip="Suppress this user"
                                            Enabled="true" OnClientClick="return Show()"
                                            CommandName="SuppressUser" Font-Italic="true"></asp:LinkButton>
                                    </ItemTemplate>
                                    <HeaderTemplate>
                                        <telerik:RadButton ID="AddNewConsultantButton" runat="server" Text="Add New" Skin="Metro" AutoPostBack="false" OnClientClicked="ShowInsertForm"></telerik:RadButton>
                                    </HeaderTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridBoundColumn DataField="Consultant" HeaderText="Consultant" HeaderStyle-Width="200px" />
                                <telerik:GridBoundColumn DataField="JobTitle" HeaderText="Title/Role" HeaderStyle-Width="200px" />
                            </Columns>
                            <NoRecordsTemplate>
                                <div style="margin-top: 10px; margin-bottom: 10px; margin-left: 5px;" id="NoRecordsDiv" runat="server">
                                    No consultants found
                                </div>
                            </NoRecordsTemplate>
                        </MasterTableView>
                        <PagerStyle Mode="NumericPages"></PagerStyle>

                        <ClientSettings>
                            <Scrolling AllowScroll="true" UseStaticHeaders="true" />
                            <Selecting AllowRowSelect="true" />
                        </ClientSettings>
                    </telerik:RadGrid>
                </asp:Panel>
            </div>
        </div>

        <asp:ObjectDataSource ID="NonGIConsultantsDatasource" runat="server" TypeName="UnisoftERS.DataAccess" SelectMethod="GetNonGIConsultants" >
          <SelectParameters>
                <asp:Parameter Name="operatingHospitalIds" DbType="string" DefaultValue="" />
            </SelectParameters>    
        </asp:ObjectDataSource>
        <telerik:RadWindowManager ID="RadWindowManager1" runat="server" Skin="Metro" Modal="true" VisibleStatusbar="false">
            <Windows>
                <telerik:RadWindow ID="ConsultantListDialog" runat="server" Title="Editing record"
                    Width="800px" Height="700px" Left="150px" ReloadOnShow="true" ShowContentDuringLoad="false"
                    Modal="true" VisibleStatusbar="false" Skin="Metro">
                </telerik:RadWindow>
            </Windows>
        </telerik:RadWindowManager>
    </form>
</body>
</html>