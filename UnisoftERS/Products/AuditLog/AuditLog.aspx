<%@ Page Title="" Language="VB" MasterPageFile="~/Templates/Unisoft.master" AutoEventWireup="false" Inherits="UnisoftERS.Products_AuditLog_AuditLog" Codebehind="AuditLog.aspx.vb" %>

<asp:Content ID="ALHead" ContentPlaceHolderID="HeadContentPlaceHolder" Runat="Server">
</asp:Content>
<asp:Content ID="ALBody" ContentPlaceHolderID="BodyContentPlaceHolder" Runat="Server">
<div class="text"><b>Reports - Audit Log</b></div>
<div>
    <telerik:RadSplitter ID="RadSplitter1" runat="server" Width="100%" BorderSize="0" Height="470">
        <telerik:RadPane ID="radLeftPane" runat="server" Width="170" Scrolling="None">
            <div style="margin-left: 18px;">
                <telerik:RadTreeView ID="radTreeList" runat="server" Skin="Office2010Silver" BorderStyle="Solid" BorderWidth="1px" BorderColor="#cfcfcf" Height="459px" />
            </div>
        </telerik:RadPane>
        <telerik:RadSplitBar ID="AuditRadSplitBar" runat="server" Visible="false" />
        <telerik:RadPane ID="radRightPane" runat="server" Scrolling="None">
            <div id="divRightContainer" style="margin-left: 4px;">
                <div id="searchBox">
                    <asp:Panel ID="Panel1" runat="server" DefaultButton="cmdSearch">
                        <telerik:RadTextBox ID="txtSearch" runat="server" Skin="Windows7" Width="300" />&nbsp;
                        <telerik:RadButton ID="cmdSearch" runat="server" Text="Search" Skin="Office2007" />
                        <telerik:RadButton ID="cmdClear" runat="server" Text="Clear" Skin="Office2007" />
                    </asp:Panel>
                    
                </div>
                <div style="background-color: #003893; color: #ffffff; padding-left: 6px; margin-top: 3px; height: 22px; padding-top: 2px;"><b>AuditLog</b> 146 events</div>
                <div id="eventGrid">
                    <telerik:RadGrid ID="radEventList" runat="server" CellSpacing="0" 
                        DataSourceID="SqlDataSource1" GridLines="None" Skin="Office2010Silver" Height="410px">
                        <ClientSettings>
                            <Scrolling AllowScroll="True" UseStaticHeaders="True" />
                        </ClientSettings>
                        <MasterTableView AutoGenerateColumns="False" DataSourceID="SqlDataSource1" HeaderStyle-Height="12px">
                            <CommandItemSettings ExportToPdfText="Export to PDF" />
                            <RowIndicatorColumn FilterControlAltText="Filter RowIndicator column" 
                                Visible="True">
                                <HeaderStyle Width="20px" />
                            </RowIndicatorColumn>
                            <ExpandCollapseColumn FilterControlAltText="Filter ExpandColumn column" 
                                Visible="True">
                                <HeaderStyle Width="20px" />
                            </ExpandCollapseColumn>
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
                            <EditFormSettings>
                                <EditColumn FilterControlAltText="Filter EditCommandColumn column">
                                </EditColumn>
                            </EditFormSettings>
                        </MasterTableView>
                        <FilterMenu EnableImageSprites="False">
                        </FilterMenu>
                    </telerik:RadGrid>                
                    <asp:SqlDataSource ID="SqlDataSource1" runat="server" 
                        ConnectionString="<%$ ConnectionStrings:Gastro_DB %>" 
                        SelectCommand="SELECT [Event Type] AS Event_Type, [Date], [Full Username] AS Full_Username, [StationID], [Event Description] AS Event_Description FROM [AuditLog] ORDER BY [Date] DESC">
                    </asp:SqlDataSource>
                </div>
            </div>
        </telerik:RadPane>
    </telerik:RadSplitter>
</div>
</asp:Content>
<asp:Content ID="ALFoot" ContentPlaceHolderID="PageFooter" Runat="Server">
</asp:Content>

