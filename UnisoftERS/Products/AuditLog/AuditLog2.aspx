<%@ Page Language="VB" MasterPageFile="~/Templates/Unisoft.master" AutoEventWireup="false" Inherits="UnisoftERS.Products_AuditLog_AuditLog2" Codebehind="AuditLog2.aspx.vb" %>

<asp:Content ID="IDHead" ContentPlaceHolderID="HeadContentPlaceHolder" runat="Server">
    <title>Audit Log</title>
    <link href="../../Styles/Site.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../Scripts/Global.js"></script>
    <style type="text/css">
        
    </style>

    <script type="text/javascript">
        
    </script>
</asp:Content>

<asp:Content ID="LeftPaneContent" runat="server" ContentPlaceHolderID="LeftPaneContentPlaceHolder">
    <div class="treeListBorder" style="margin-top: -5px;">
        <telerik:RadTreeView ID="LeftMenuTreeView" runat="server" Skin="Metro" BackColor="#ffffff" />
    </div>
</asp:Content>

<asp:Content ID="IDBody" ContentPlaceHolderID="BodyContentPlaceHolder" runat="Server">
    <div>
        <telerik:RadSplitter ID="radMainPage" runat="server" Width="100%" BorderSize="0" Height="640px" Skin="Office2007">
            <telerik:RadPane ID="radRightPane" runat="server" Scrolling="None">
                <telerik:RadFormDecorator ID="AuditLogRadFormDecorator" runat="server" DecoratedControls="All"
                            DecorationZoneID="AuditLogDiv" Skin="Metro" />
                <div id="AuditLogDiv">
                    <telerik:RadMultiPage ID="radProducts" runat="server" SelectedIndex="0">
                        <telerik:RadPageView ID="pageAuditLog" runat="server">
                            <div style="margin: 5px 5px;">
                                <div style="height: 25px;"></div>                            
                                <div id="divSearch">
                                    <asp:Panel ID="Panel1" runat="server" DefaultButton="cmdSearch">
                                        <table id="tableSearchOptions" runat="server" cellspacing="0" cellpadding="0">
                                            <tr>
                                                <td style="width: 307px;"><telerik:RadTextBox ID="txtSearch" runat="server" Skin="Windows7" Width="300" /></td>
                                                <td><telerik:RadButton ID="cmdSearch" runat="server" Text="Search" Skin="Web20" Font-Bold="true" />&nbsp;</td>
                                                <td><telerik:RadButton ID="cmdClear" runat="server" Text="Clear" Skin="Web20" />&nbsp;</td>
                                            </tr>
                                        </table>
                                    </asp:Panel>
                                </div>
                                <div style="margin-top: 5px;">
                                    <telerik:RadGrid ID="uniRadGrid" runat="server" CellSpacing="0" GridLines="None" Skin="Windows7" PageSize="50" AllowPaging="true" Height="600px">
                                        <MasterTableView AutoGenerateColumns="false" ShowHeadersWhenNoRecords="true" HeaderStyle-Height="12px">
                                            <Columns>
                                                <telerik:GridBoundColumn DataField="Event_Type" DataType="System.Int16" 
                                                    FilterControlAltText="Filter Event_Type column" HeaderText="Type" 
                                                    SortExpression="Event_Type" UniqueName="Event_Type" HeaderStyle-Width="100px" HeaderStyle-Font-Bold="true">
                                                </telerik:GridBoundColumn>
                                                <telerik:GridBoundColumn DataField="Date" DataType="System.DateTime" 
                                                    FilterControlAltText="Filter Date column" HeaderText="Date" 
                                                    SortExpression="Date" UniqueName="Date" HeaderStyle-Width="140px" HeaderStyle-Font-Bold="true">
                                                </telerik:GridBoundColumn>
                                                <telerik:GridBoundColumn DataField="Full_Username" 
                                                    FilterControlAltText="Filter Full_Username column" HeaderText="User" 
                                                    SortExpression="Full_Username" UniqueName="Full_Username" HeaderStyle-Width="120px" HeaderStyle-Font-Bold="true">
                                                </telerik:GridBoundColumn>
                                                <telerik:GridBoundColumn DataField="StationID" 
                                                    FilterControlAltText="Filter StationID column" HeaderText="Location" 
                                                    SortExpression="StationID" UniqueName="StationID" HeaderStyle-Width="100px" HeaderStyle-Font-Bold="true">
                                                </telerik:GridBoundColumn>
                                                <telerik:GridBoundColumn DataField="Event_Description" 
                                                    FilterControlAltText="Filter Event_Description column" 
                                                    HeaderText="Event Description" SortExpression="Event_Description" 
                                                    UniqueName="Event_Description" HeaderStyle-Font-Bold="true">
                                                </telerik:GridBoundColumn>
                                            </Columns>
                                            <NoRecordsTemplate>
                                                <div style="margin-left: 5px;">No records found</div>
                                            </NoRecordsTemplate>
                                        </MasterTableView>
                                        <PagerStyle Mode="NextPrev" />
                                        <ClientSettings>
                                            <Selecting AllowRowSelect="True" />
                                            <Scrolling AllowScroll="True" UseStaticHeaders="True" />
                                        </ClientSettings>
                                    </telerik:RadGrid>
                                </div>                            
                            </div>


                        </telerik:RadPageView>
                    </telerik:RadMultiPage>
                </div>            
            </telerik:RadPane>        
        </telerik:RadSplitter>
    </div>
</asp:Content>
