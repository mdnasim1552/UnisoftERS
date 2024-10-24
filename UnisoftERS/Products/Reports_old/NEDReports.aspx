<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="NEDReports.aspx.vb" Inherits="UnisoftERS.NEDReports" %>
<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager2" runat="server" />
    <script type="text/javascript" src="../../Scripts/Global.js"></script>
    <script type="text/javascript" src="../../Scripts/jquery-1.11.0.min.js"></script>
    <link href="../../Styles/Site.css" rel="stylesheet" />
    <link href="/Styles/Reporting.css" rel="stylesheet" />
    <script type="text/javascript" src="/Scripts/Reports.js"></script>
    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <script type="text/javascript">
            // The JQuery code here
            function ViewXML(sender, args) {
                columnName = args.get_column().get_uniqueName();
                if (columnName == 'LogId') {
                    var p = args.get_gridDataItem().getDataKeyValue("LogId") + '';
                    radopen("xmlW.aspx?LogId=".concat(p));
                }
                return false;
            }
            $(document).ready(function () {
            });
        </script>
    </telerik:RadScriptBlock>

</head>
<body>
    <form id="form1" runat="server">
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server">
            <Scripts>
                <asp:ScriptReference Assembly="Telerik.Web.UI" Name="Telerik.Web.UI.Common.Core.js">
                </asp:ScriptReference>
                <asp:ScriptReference Assembly="Telerik.Web.UI" Name="Telerik.Web.UI.Common.jQuery.js">
                </asp:ScriptReference>
                <asp:ScriptReference Assembly="Telerik.Web.UI" Name="Telerik.Web.UI.Common.jQueryInclude.js">
                </asp:ScriptReference>
            </Scripts>
        </telerik:RadScriptManager>
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server">
        </telerik:RadAjaxManager>
        <div id="ContentDiv">
            <div class="otherDataHeading">
                NED log
            </div>
            <asp:Panel ID="Panel1" runat="server" CssClass="background1">
                <div class="optionsBodyText" id="NEDForm">
                    <div id="NEDRDates">
                        <fieldset>
                            <legend>Range of Dates</legend>
                            <div class="unFromDate">
                                From:<br />
                                <telerik:RadDatePicker ID="RDPFrom" Runat="server" Culture="en-GB" SkinID="RadSkinManager1" ToolTip="First date to be used in the report" Skin="Bootstrap" SelectedDate="1980-01-01" >
                                    <Calendar EnableWeekends="True" FastNavigationNextText="&amp;lt;&amp;lt;" UseColumnHeadersAsSelectors="False" UseRowHeadersAsSelectors="False" runat="server" Culture="en-GB" >
                                    </Calendar>
                                    <DateInput runat="server" DateFormat="dd/MM/yyyy" DisplayDateFormat="dd/MM/yyyy" LabelWidth="30%" value="01/01/1980" ValidationGroup="FilterGroup" DisplayText="01/01/1980" SelectedDate="1980-01-01">
                                    <EmptyMessageStyle Resize="None" />
                                    <ReadOnlyStyle Resize="None" />
                                    <FocusedStyle Resize="None" />
                                    <DisabledStyle Resize="None" />
                                    <InvalidStyle Resize="None" />
                                    <HoveredStyle Resize="None" />
                                    <EnabledStyle Resize="None" />
                                    </DateInput>
                                    <DatePopupButton HoverImageUrl="" ImageUrl="" />
                                </telerik:RadDatePicker>
                            </div>
                            <div class="unToDate">
                                To:<br />
                                <telerik:RadDatePicker ID="RDPTo" Runat="server" Culture="en-GB" SkinID="RadSkinManager1" Skin="Bootstrap" SelectedDate="2099-12-31">
                                    <Calendar EnableWeekends="True" FastNavigationNextText="&amp;lt;&amp;lt;" UseColumnHeadersAsSelectors="False" UseRowHeadersAsSelectors="False" runat="server" SkinID="RadSkinManager1" Culture="en-GB">
                                    </Calendar>
                                    <DateInput DateFormat="dd/MM/yyyy" DisplayDateFormat="dd/MM/yyyy" LabelWidth="30%" runat="server" ValidationGroup="FilterGroup" DisplayText="31/12/2099" SelectedDate="2099-12-31" value="31/12/2099">
                                    <EmptyMessageStyle Resize="None" />
                                    <ReadOnlyStyle Resize="None" />
                                    <FocusedStyle Resize="None" />
                                    <DisabledStyle Resize="None" />
                                    <InvalidStyle Resize="None" />
                                    <HoveredStyle Resize="None" />
                                    <EnabledStyle Resize="None" />
                                    </DateInput>
                                    <DatePopupButton/>
                                </telerik:RadDatePicker>
                            </div>
                            <div class="autosize">
                                <asp:TextBox runat="server" ID="SUID" CssClass="secret"></asp:TextBox>
                                <asp:RequiredFieldValidator runat="server" ID="RequiredFieldValidatorFromDate" ControlToValidate="RDPFrom" ErrorMessage="Enter a date!" SetFocusOnError="True" ValidationGroup="FilterGroup" ForeColor="Red"></asp:RequiredFieldValidator><br />
                                <asp:RequiredFieldValidator runat="server" ID="RequiredfieldvalidatorToDate" ControlToValidate="RDPTo" ErrorMessage="Enter a date!" ValidationGroup="FilterGroup" ForeColor="Red"></asp:RequiredFieldValidator>
                                <asp:CompareValidator ID="dateCompareValidator" runat="server" ControlToValidate="RDPTo" ControlToCompare="RDPFrom" Operator="GreaterThan" ValidationGroup="FilterGroup" Type="Date" ErrorMessage="The second date must be after the first one." SetFocusOnError="True" ForeColor="Red"></asp:CompareValidator>
                            </div>
                        </fieldset>
                    </div>
                    <div id="NEDRPatient">
                        <fieldset>
                            <legend>Search by patient</legend>
                            <div class="autosize">
                                <asp:Label ID="PatientNameLabel" runat="server" Text="Patient name"></asp:Label><br />
                                <input id="PatientName" runat="server" type="text" />
                            </div>
                            <div class="autosize">
                                <asp:Label ID="CNNLabel" runat="server" Text="Case note No"></asp:Label><br />
                                <input id="CNN" runat="server" type="text" />
                            </div>
                            <div class="autosize">
                                <asp:Label ID="NHSLabel" runat="server" Text="NHS No"></asp:Label><br />
                                <input id="NHS" runat="server" type="text" />
                            </div>
                            <div class="autosize">
                                
                            </div>
                        </fieldset>
                    </div>
                    <div id="NEDRFilter">
                        <fieldset>
                            <legend>Filtering conditions</legend>
                            <asp:Label ID="lProcedureTypeId" runat="server" Text="Procedure Type"></asp:Label>
                            <asp:radioButtonList ID="ProcedureTypeId" runat="server" RepeatDirection="Horizontal" Rows="1">
                                <asp:ListItem Value="0" Selected="True">All</asp:ListItem>
                                <asp:ListItem Value="1">OGD</asp:ListItem>
                                <asp:ListItem Value="2">ERCP</asp:ListItem>
                                <asp:ListItem Value="3">Col.</asp:ListItem>
                                <asp:ListItem Value="4">Sig.</asp:ListItem>
                            </asp:radioButtonList>                                
                            <div class="autosize">
                                <asp:radioButtonList ID="IsProcessed" runat="server" Rows="1">
                                    <asp:ListItem Value="0" Selected="True">All</asp:ListItem>
                                    <asp:ListItem Value="1">Processed</asp:ListItem>
                                    <asp:ListItem Value="2">Not rocessed</asp:ListItem>
                                </asp:radioButtonList>                                
                            </div>
                            <div class="autosize">
                                <asp:radioButtonList ID="IsSchemaValid" runat="server" Rows="1">
                                    <asp:ListItem Value="0" Selected="True">All</asp:ListItem>
                                    <asp:ListItem Value="1">Schema Valid</asp:ListItem>
                                    <asp:ListItem Value="2">Schema invalid</asp:ListItem>
                                </asp:radioButtonList>                                
                            </div>
                            <div class="autosize">
                                <asp:radioButtonList ID="IsSent" runat="server" Rows="1">
                                    <asp:ListItem Value="0" Selected="True">All</asp:ListItem>
                                    <asp:ListItem Value="1">Sent</asp:ListItem>
                                    <asp:ListItem Value="2">Not sent</asp:ListItem>
                                </asp:radioButtonList>                                
                            </div>
                            <div class="autosize">
                                <asp:radioButtonList ID="IsRejected" runat="server" Rows="1">
                                    <asp:ListItem Value="0" Selected="True">All</asp:ListItem>
                                    <asp:ListItem Value="1">Rejected</asp:ListItem>
                                    <asp:ListItem Value="2">Not rejected</asp:ListItem>
                                </asp:radioButtonList>                                
                            </div>
                            <div class="autosize">
                                <telerik:RadButton ID="Go" runat="server" Text="Filter" Skin="Web20" CssClass="PrintXmlReport" OnClientClicking="ValidatingDates" >
                                </telerik:RadButton>                                
                            </div>
                        </fieldset>
                    </div>
                </div>
                <div class="optionsBodyText" id="NEDGrid">
                    <telerik:RadGrid ID="RadGridNED" runat="server" AllowPaging="True" AutoGenerateColumns="False" GroupPanelPosition="Top" CellSpacing="-1" GridLines="Both">
                        <GroupingSettings CollapseAllTooltip="Collapse all groups" />
                            <ClientSettings>
                                <Scrolling AllowScroll="True" UseStaticHeaders="True" />
                                <Selecting CellSelectionMode="SingleCell" />
                                <ClientEvents OnCellSelected="ViewXML" ></ClientEvents>
                            </ClientSettings>
                        <MasterTableView DataSourceID="DSNEDLog" DataKeyNames="LogId" ClientDataKeyNames="LogId">
                            <Columns>
                                <telerik:GridBoundColumn DataField="LogId" DataType="System.Int32" FilterControlAltText="Filter LogId column" HeaderText="LogId" SortExpression="LogId" UniqueName="LogId1">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn DataField="ProcedureType" FilterControlAltText="Filter ProcedureType column" HeaderText="ProcedureType" SortExpression="ProcedureType" UniqueName="ProcedureType">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn DataField="PatientName" FilterControlAltText="Filter PatientName column" HeaderText="PatientName" ReadOnly="True" SortExpression="PatientName" UniqueName="PatientName">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn DataField="logDate" DataType="System.DateTime" FilterControlAltText="Filter logDate column" HeaderText="logDate" SortExpression="logDate" UniqueName="logDate">
                                </telerik:GridBoundColumn>
                                <telerik:GridCheckBoxColumn DataField="IsProcessed" DataType="System.Boolean" FilterControlAltText="Filter IsProcessed column" HeaderText="IsProcessed" SortExpression="IsProcessed" UniqueName="IsProcessed">
                                </telerik:GridCheckBoxColumn>
                                <telerik:GridCheckBoxColumn DataField="IsSchemaValid" DataType="System.Boolean" FilterControlAltText="Filter IsSchemaValid column" HeaderText="IsSchemaValid" SortExpression="IsSchemaValid" UniqueName="IsSchemaValid">
                                </telerik:GridCheckBoxColumn>
                                <telerik:GridCheckBoxColumn DataField="IsSent" DataType="System.Boolean" FilterControlAltText="Filter IsSent column" HeaderText="IsSent" SortExpression="IsSent" UniqueName="IsSent">
                                </telerik:GridCheckBoxColumn>
                                <telerik:GridCheckBoxColumn DataField="IsRejected" DataType="System.Boolean" FilterControlAltText="Filter IsRejected column" HeaderText="IsRejected" SortExpression="IsRejected" UniqueName="IsRejected">
                                </telerik:GridCheckBoxColumn>
                                <telerik:GridImageColumn UniqueName="LogId" ImageUrl="~/Images/icons/notes.png" HeaderText="View XML"></telerik:GridImageColumn>
                                <telerik:GridBoundColumn DataField="NEDMessage" FilterControlAltText="Filter NEDMessage column" HeaderText="NEDMessage" SortExpression="NEDMessage" UniqueName="NEDMessage" EmptyDataText="xml" HtmlEncode="false" ReadOnly="True"></telerik:GridBoundColumn>                                
                            </Columns>
                        </MasterTableView>
                    </telerik:RadGrid>
                </div>
                <asp:ObjectDataSource ID="DSNEDLog" runat="server" SelectMethod="GetNEDLog" TypeName="UnisoftERS.NedClass">
                </asp:ObjectDataSource>
                <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:Gastro_StokeConnectionString %>" SelectCommand="SELECT [LogId], [ProcedureType], [CNN], [NHS], [PatientName], [logDate], [IsProcessed], [IsSchemaValid], [IsSent], [IsRejected], [NEDMessage], [TimesSent] FROM [v_rep_NEDLog]"></asp:SqlDataSource>
            </asp:Panel>
            <telerik:RadWindowManager ID="RadWindowManager1" runat="server" Animation="Fade" AutoSize="true" Modal="True" RenderMode="Classic" VisibleStatusbar="False" Skin="Office2007" MinHeight="500px" MinWidth="650px">
                <Windows>
                    <telerik:RadWindow ID="RadWindow1" runat="server" Title="Related procedures" VisibleOnPageLoad="False" MinHeight="500px" MinWidth="650px" AutoSize="true" VisibleStatusbar="false" Modal="true">
                        <ContentTemplate>
                        <div id="MiniWindow1">
                        </div>
                        </ContentTemplate>
                    </telerik:RadWindow>
                </Windows>
            </telerik:RadWindowManager>
            </div>
    </form>
</body>
</html>
