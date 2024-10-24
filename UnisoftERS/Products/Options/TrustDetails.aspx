<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="TrustDetails.aspx.vb" Inherits="UnisoftERS.TrustDetails" %>

<!DOCTYPE html>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../Scripts/Global.js"></script>
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <link type="text/css" href="../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
        .optionsHeadingNote_bgWhite table td:first-child {
            width: 160px;
        }
    </style>
    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <script type="text/javascript">
            function addTrust(rowIndex) {
                if (rowIndex > -1) {
                    var gvID = $find('<%=TrustsRadGrid.ClientID %>');
                    var masterTableView = gvID.get_masterTableView();
                    var TrustDataItems = masterTableView.get_dataItems()[rowIndex];
                    //get the datakeyname
                    var TrustId = TrustDataItems.getDataKeyValue("TrustId");

                    var url = "<%= ResolveUrl("~/Products/Options/EditTrust.aspx?TrustId={0}")%>";
                    url = url.replace("{0}", TrustId);
                }
                else {
                    var url = "<%= ResolveUrl("~/Products/Options/EditTrust.aspx")%>";
                }
                var oWnd = $find("<%= NewEditTrustWindow.ClientID %>");
                oWnd._navigateUrl = url
                oWnd.SetSize(500, 150);

                //Add the name of the function to be executed when RadWindow is closed.

                oWnd.show();
                
                
            }        

            function refreshGrid() {
                //var oWnd = $find("<%= NewEditTrustWindow.ClientID %>");
                //oWnd.hide();
                $find("<%= RadAjaxManager1.ClientID %>").ajaxRequest("Rebind");
                
            }        
        </script>
    </telerik:RadScriptBlock>

</head>
<body>
    <form id="form1" runat="server">

        <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server">
            <AjaxSettings>
                <telerik:AjaxSetting AjaxControlID="RadAjaxManager1">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="TrustsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="TrustsRadGrid">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="TrustsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
        </telerik:RadAjaxManager>

        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Metro" />
        <telerik:RadFormDecorator ID="RadFormDecorator2" runat="server" DecoratedControls="All" DecorationZoneID="CopySettingsDiv" Skin="Metro" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro" />
        <div class="optionsHeading">
            <asp:Label ID="HeadingLabel" runat="server" Text="Trusts"></asp:Label>
        </div>
        <div id="FormDiv" runat="server" style="margin-top: 10px;">
            <div style="margin-left: 10px; margin-top: 20px;" class="rptText">
                <telerik:RadGrid ID="TrustsRadGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false" AllowSorting="true"
                    DataSourceID="TrustsDataSource"
                    Skin="Metro" AllowPaging="false" Style="margin-bottom: 10px; width: 75%; height: 500px;">
                    <HeaderStyle Font-Bold="true" />
                    <MasterTableView ShowHeadersWhenNoRecords="true" ClientDataKeyNames="TrustId,TrustName" DataKeyNames="TrustId,TrustName" TableLayout="Fixed"
                        EnableNoRecordsTemplate="true" CssClass="MasterClass">
                        <Columns>
                            <telerik:GridTemplateColumn UniqueName="EditLinkButtonColumn" HeaderStyle-Width="65px">
                                <ItemTemplate>
                                    <asp:LinkButton ID="EditLinkButton" runat="server" Text="Edit" ToolTip="Edit Trust" Font-Italic="true"></asp:LinkButton>
                                </ItemTemplate>
                                <HeaderTemplate>
                                    <%--<telerik:RadButton ID="AddNewImagePortButton" runat="server" Text="Add New ImagePort" Skin="Windows7" OnClientClicked=""   AutoPostBack="false" />--%>
                                    <telerik:RadButton ID="AddNewTrustButton" runat="server" OnClientClicked="addTrust" Text="Add New" Skin="Metro" AutoPostBack="false" Visible="false"></telerik:RadButton>
                                </HeaderTemplate>
                            </telerik:GridTemplateColumn>

                            <telerik:GridBoundColumn DataField="TrustName" HeaderText="Trust name" SortExpression="TrustName" HeaderStyle-Width="300px" AllowSorting="true" ShowSortIcon="true" />
     
                        </Columns>
                        <NoRecordsTemplate>
                            <div style="margin-top: 10px; margin-bottom: 10px; margin-left: 5px;" id="NoRecordsDiv" runat="server">
                                No trusts found.
                            </div>
                        </NoRecordsTemplate>
                    </MasterTableView>

                    <ClientSettings>
                        <Scrolling AllowScroll="true" UseStaticHeaders="true" />
                        <Selecting AllowRowSelect="true" />
                    </ClientSettings>
                </telerik:RadGrid>
                <asp:ObjectDataSource ID="TrustsDataSource" runat="server" TypeName="UnisoftERS.DataAccess" SelectMethod="GetAllTrusts">
                    <UpdateParameters>
                        <asp:Parameter Name="TrustId" DbType="Int32" DefaultValue="" />
                        <asp:Parameter Name="TrustName" DbType="String" DefaultValue="" />
                    </UpdateParameters>
                    <InsertParameters>
                        <asp:Parameter Name="TrustId" DbType="Int32" DefaultValue="" />
                        <asp:Parameter Name="TrustName" DbType="String" DefaultValue="" />
                    </InsertParameters>
                </asp:ObjectDataSource>
            </div>
        </div>
        <telerik:RadWindowManager ID="TrustsRadWindowManager" runat="server"
            Style="z-index: 7001" Behaviors="Close, Move" AutoSize="false" Skin="Metro" EnableShadow="true" Modal="true">
            <Windows>
                <telerik:RadWindow ID="NewEditTrustWindow" runat="server" Modal="true" ReloadOnShow="true" KeepInScreenBounds="true"
                    Width="500px" Height="200px" Title="Add/Edit Trust" VisibleStatusbar="false" />
            </Windows>
        </telerik:RadWindowManager>
    </form>
</body>
</html>
