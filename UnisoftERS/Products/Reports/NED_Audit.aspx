<%@ Page Language="vb" AutoEventWireup="false" MasterPageFile="~/Templates/Reports.Master" CodeBehind="NED_Audit.aspx.vb" Inherits="UnisoftERS.NEDReports" %>

<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContentPlaceHolder2" runat="server">
    <link href="../../Styles/bootstrap.min.css" rel="stylesheet" />
    <style type="text/css">
        .otherDataHeading {
            box-sizing: unset;
        }

        #patient-search-filter td {
            padding-left: 10px;
        }

        .dateFilterDiv {
            float: left;
        }

        .date-filter {
            width: 195px !important;
        }
    </style>
</asp:Content>
<asp:Content ID="MainBodyContent" ContentPlaceHolderID="BodyContentPlaceHolder" runat="server">

    <telerik:RadFormDecorator ID="MultiPageSystemDecorator" runat="server" DecoratedControls="All" DecorationZoneID="ContentDiv" Skin="Metro" />
    <div class="otherDataHeading">National Data Set Audit log</div>
    <asp:UpdatePanel runat="server">
        <ContentTemplate>
            <asp:Panel ID="ContentPanel" runat="server" Style="padding-left: 1em;" ScrollBars="Vertical" Height="627px">
                <div id="ContentDiv">
                    <div class="optionsBodyText row" id="NEDForm">
                        <table>
                            <tr>
                                <td>
                                    <fieldset class="padding1em">
                                        <legend>Range of Dates</legend>
                                        <div class="dateFilterDiv" style="padding-right: 55px;">
                                            From:<br />
                                            <telerik:RadDatePicker ID="RDPFrom" CssClass="date-filter" runat="server" Culture="en-GB" SkinID="RadSkinManager1" ToolTip="First date to be used in the report" Skin="Metro">
                                                <Calendar EnableWeekends="True" FastNavigationNextText="&amp;lt;&amp;lt;" UseColumnHeadersAsSelectors="False" UseRowHeadersAsSelectors="False" runat="server" Culture="en-GB">
                                                </Calendar>
                                                <DateInput runat="server" DateFormat="dd/MM/yyyy" DisplayDateFormat="dd/MM/yyyy" LabelWidth="30%" value="01/01/1980" ValidationGroup="FilterGroup">
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
                                        <div class="dateFilterDiv">
                                            To:<br />
                                            <telerik:RadDatePicker ID="RDPTo" CssClass="date-filter" runat="server" Culture="en-GB" SkinID="RadSkinManager1" Skin="Metro">
                                                <Calendar EnableWeekends="True" FastNavigationNextText="&amp;lt;&amp;lt;" UseColumnHeadersAsSelectors="False" UseRowHeadersAsSelectors="False" runat="server" SkinID="RadSkinManager1" Culture="en-GB">
                                                </Calendar>
                                                <DateInput DateFormat="dd/MM/yyyy" DisplayDateFormat="dd/MM/yyyy" LabelWidth="30%" runat="server" ValidationGroup="FilterGroup">
                                                    <EmptyMessageStyle Resize="None" />
                                                    <ReadOnlyStyle Resize="None" />
                                                    <FocusedStyle Resize="None" />
                                                    <DisabledStyle Resize="None" />
                                                    <InvalidStyle Resize="None" />
                                                    <HoveredStyle Resize="None" />
                                                    <EnabledStyle Resize="None" />
                                                </DateInput>
                                                <DatePopupButton />
                                            </telerik:RadDatePicker>
                                        </div>
                                        <div class="autosize">
                                            <%--<asp:TextBox runat="server" ID="SUID" CssClass="secret"></asp:TextBox>--%>
                                            <asp:RequiredFieldValidator runat="server" ID="RequiredFieldValidatorFromDate" ControlToValidate="RDPFrom" ErrorMessage="Enter a date!" SetFocusOnError="True" ValidationGroup="FilterGroup" ForeColor="Red"></asp:RequiredFieldValidator>
                                            <asp:RequiredFieldValidator runat="server" ID="RequiredfieldvalidatorToDate" ControlToValidate="RDPTo" ErrorMessage="Enter a date!" ValidationGroup="FilterGroup" ForeColor="Red"></asp:RequiredFieldValidator>
                                            <asp:CompareValidator ID="dateCompareValidator" runat="server" ControlToValidate="RDPTo" ControlToCompare="RDPFrom" Operator="GreaterThan" ValidationGroup="FilterGroup" Type="Date" ErrorMessage="The second date must be after the first one." SetFocusOnError="True" ForeColor="Red"></asp:CompareValidator>
                                        </div>
                                    </fieldset>
                                </td>
                                <td valign="top">
                                    <fieldset class="padding1em">
                                        <legend>Procedure Type</legend>
                                        <div style="padding: 10px;">
                                            <asp:CheckBox runat="server" ID="AllProcedureTypesCheckbox" Text="All" /><br />
                                            <asp:CheckBoxList ID="chkProcedureType" runat="server" RepeatDirection="Horizontal">
                                                <asp:ListItem Value="1" Selected="True">OGD</asp:ListItem>
                                                <asp:ListItem Value="2" Selected="True">ERCP</asp:ListItem>
                                                <asp:ListItem Value="3" Selected="True">Col.</asp:ListItem>
                                                <asp:ListItem Value="4" Selected="True">Sig.</asp:ListItem>
                                            </asp:CheckBoxList>
                                        </div>
                                    </fieldset>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <fieldset class="padding1em">
                                        <legend>Search by</legend>
                                        <table id="patient-search-filter">
                                            <tr>
                                                <td>
                                                    <asp:Label ID="PatientNameLabel" runat="server" Text="Patient name"></asp:Label><br />
                                                    <input id="PatientName" runat="server" type="text" />
                                                </td>
                                                <td>
                                                    <asp:Label ID="CNNLabel" runat="server" Text="Hospital No"></asp:Label><br />
                                                    <input id="CNN" runat="server" type="text" />
                                                </td>
                                                <td>
                                                    <asp:Label ID="NHSLabel" runat="server" Text="NHS No"></asp:Label><br />
                                                    <input id="NHS" runat="server" type="text" style="width: 85px;" />
                                                </td>
                                            </tr>
                                        </table>
                                    </fieldset>
                                </td>
                                <td valign="top">
                                    <fieldset class="padding1em">
                                        <legend>File Status</legend>
                                        <asp:RadioButtonList ID="IsSent" runat="server" RepeatDirection="Horizontal" Rows="1">
                                            <asp:ListItem Value="0" Selected="True">All</asp:ListItem>
                                            <asp:ListItem Value="1">Sent</asp:ListItem>
                                            <asp:ListItem Value="2">Not sent</asp:ListItem>
                                        </asp:RadioButtonList>
                                        <asp:RadioButtonList ID="IsRejected" runat="server" RepeatDirection="Horizontal" Rows="1">
                                            <asp:ListItem Value="0" Selected="True">All</asp:ListItem>
                                            <asp:ListItem Value="1">Rejected</asp:ListItem>
                                            <asp:ListItem Value="2">Not rejected</asp:ListItem>
                                        </asp:RadioButtonList>
                                    </fieldset>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2" style="text-align: right; padding-top:5px;">
                                    <telerik:RadButton ID="Go" runat="server" Skin="Silk" Text="Preview" CssClass="PrintXmlReport" Icon-PrimaryIconCssClass="telerikPreviewButton">
                                        <%--OnClientClicking="ValidatingDates"--%>
                                    </telerik:RadButton>
                                </td>
                            </tr>
                        </table>

                    </div>
                </div>

                <div class="optionsBodyText" id="NEDGrid">
                    <telerik:RadGrid ID="RadGridNED" Skin="Office2010Blue" runat="server" AllowPaging="True" AutoGenerateColumns="False" AllowSorting="true" GroupPanelPosition="Top" CellSpacing="-1" GridLines="Both" Width="1200">
                        <GroupingSettings CollapseAllTooltip="Collapse all groups" />
                        <ClientSettings>
                            <Scrolling AllowScroll="True" UseStaticHeaders="True" />
                            <Selecting CellSelectionMode="SingleCell" />
                            <ClientEvents OnCellSelected="ViewXML"></ClientEvents>
                        </ClientSettings>
                        <MasterTableView DataSourceID="DSNEDLog" DataKeyNames="LogId" ClientDataKeyNames="LogId">
                            <Columns>
                                <telerik:GridImageColumn UniqueName="LogId" ImageUrl="~/Images/icons/notes.png" HeaderText="" ItemStyle-CssClass="image-link" HeaderStyle-Width="30"></telerik:GridImageColumn>
                                <telerik:GridBoundColumn DataField="logDate" DataType="System.DateTime" FilterControlAltText="Filter logDate column" HeaderText="Date & Time" SortExpression="logDate" UniqueName="logDate" HeaderStyle-Width="150">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn DataField="ProcedureType" FilterControlAltText="Filter ProcedureType column" HeaderText="Procedure Type" SortExpression="ProcedureType" UniqueName="ProcedureType" HeaderStyle-Width="150">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn DataField="PatientName" FilterControlAltText="Filter PatientName column" HeaderText="Patient Name" ReadOnly="True" SortExpression="PatientName" UniqueName="PatientName" HeaderStyle-Width="250">
                                </telerik:GridBoundColumn>
                                <telerik:GridCheckBoxColumn DataField="IsProcessed" DataType="System.Boolean" FilterControlAltText="Filter IsProcessed column" HeaderText="Processed" SortExpression="IsProcessed" UniqueName="IsProcessed" HeaderStyle-Width="100">
                                </telerik:GridCheckBoxColumn>
                                <telerik:GridCheckBoxColumn DataField="IsSchemaValid" DataType="System.Boolean" FilterControlAltText="Filter IsSchemaValid column" HeaderText="Valid Schema" SortExpression="IsSchemaValid" UniqueName="IsSchemaValid" HeaderStyle-Width="100">
                                </telerik:GridCheckBoxColumn>
                                <telerik:GridCheckBoxColumn DataField="IsSent" DataType="System.Boolean" FilterControlAltText="Filter IsSent column" HeaderText="Exported" SortExpression="IsSent" UniqueName="IsSent" HeaderStyle-Width="100">
                                    <%-- ItemStyle-CssClass="align-centre" HeaderStyle-CssClass="align-centre">--%>
                                </telerik:GridCheckBoxColumn>
                                <telerik:GridCheckBoxColumn DataField="IsSuccess" DataType="System.Boolean" FilterControlAltText="Filter IsSuccess column" HeaderText="Success" SortExpression="IsSuccess" UniqueName="IsSuccess" HeaderStyle-Width="100">
                                    <%-- ItemStyle-CssClass="align-centre" HeaderStyle-CssClass="align-centre">--%>
                                </telerik:GridCheckBoxColumn>
                                <telerik:GridBoundColumn DataField="ShortMessage" FilterControlAltText="Filter NEDMessage column" HeaderText="Failed reason" SortExpression="ShortMessage" UniqueName="ShortMessage" EmptyDataText="" HtmlEncode="false" ReadOnly="True" HeaderStyle-Width="200"></telerik:GridBoundColumn>
                                <telerik:GridBoundColumn DataField="NEDMessage" FilterControlAltText="Filter NEDMessage column" HeaderText="" UniqueName="NEDMessage" EmptyDataText="" HtmlEncode="false" ReadOnly="True" ItemStyle-Width="1" HeaderStyle-Width="1" ItemStyle-Wrap="False"></telerik:GridBoundColumn>
                            </Columns>
                        </MasterTableView>
                    </telerik:RadGrid>
                </div>
                <asp:ObjectDataSource ID="DSNEDLog" runat="server" SelectMethod="GetNEDLog" TypeName="UnisoftERS.NedClass"></asp:ObjectDataSource>
                <%--<asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:Gastro_StokeConnectionString %>" SelectCommand="SELECT [LogId], [ProcedureType], [CNN], [NHS], [PatientName], [logDate], [IsProcessed], [IsSchemaValid], [IsSent], [IsRejected], [NEDMessage], [TimesSent] FROM [v_rep_NEDLog]"></asp:SqlDataSource>--%>
                <asp:SqlDataSource ID="SqlDataSource1" runat="server" SelectCommand="SELECT [LogId], [ProcedureType], [CNN], [NHS], [PatientName], [logDate], [IsProcessed], [IsSchemaValid], [IsSent], [IsSuccess], [NEDMessage], [TimesSent] FROM [v_rep_NEDLog]"></asp:SqlDataSource>

                <telerik:RadWindowManager ID="RadWindowManager1" runat="server" Animation="Fade" AutoSize="true" Modal="true" RenderMode="Classic" VisibleStatusbar="False" Skin="Metro" ClientIDMode="Static">
                    <Windows>
                        <telerik:RadWindow ID="rwExportMessage" runat="server" Title="Export Message" VisibleOnPageLoad="False" AutoSize="false" Width="400px" Height="200px" VisibleStatusbar="false" Modal="true">
                            <ContentTemplate>
                                <div id="exportStatusMessageTextDiv">
                                    <h2 style="color: blue; padding-left: 10px;">Export status message</h2>
                                    <h3 style="color: red; padding-left: 2em;"><span id="exportMessageText">my own text</span></h3>
                                </div>

                                <div style="position: absolute; bottom: 2em; right: 2em;">
                                    <telerik:RadButton ID="cancelwindowbutton" runat="server" Text="Close" AutoPostBack="false" Skin="Web20" OnClientClicked="closeRadWindowExportMessage" TabIndex="93" Icon-PrimaryIconCssClass="telerikCancelButton" />
                                </div>

                            </ContentTemplate>
                        </telerik:RadWindow>

                        <%--                    <telerik:RadWindow ID="RadWindow1" runat="server" Title="Related procedures" VisibleOnPageLoad="False" AutoSize="true" VisibleStatusbar="false" Modal="true" ClientIDMode="Static">
                        <ContentTemplate>
                        
                        </ContentTemplate>
                    </telerik:RadWindow>--%>
                    </Windows>
                </telerik:RadWindowManager>
                </div>
            </asp:Panel>




            <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
                <script type="text/javascript">
                    // The JQuery code here
                    function ViewXML(sender, args) {
                        $("body").css("cursor", "wait");

                        columnName = args.get_column().get_uniqueName();
                        if (columnName == 'LogId') {
                            var p = args.get_gridDataItem().getDataKeyValue("LogId") + '';
                            radopen("xmlW.aspx?LogId=".concat(p), "xmlPreviewWindow", 1200, 700, 20, 20);
                        }

                        if (columnName == 'ShortMessage') {
                            //var nedMessage = args.get_gridDataItem().getDataKeyValue("NEDMessage") + '';
                            var data = args.get_gridDataItem().get_cell("NEDMessage");
                            var selectedValue = data.innerHTML;
                            //alert(selectedValue);     //Get the cell value
                            if (selectedValue != '') {
                                $("#exportMessageText").text(selectedValue);

                                var oWnd = $find("<%= rwExportMessage.ClientID%>");
                                oWnd.show();
                            }
                        }

                        $("body").css("cursor", "default");

                        return false;
                    }

                    function closeRadWindowExportMessage() {
                        var oWnd = $find("<%= rwExportMessage.ClientID%>");
                        if (oWnd != null)
                            oWnd.close();
                        return false;
                    }



                    $(document).ready(function () {
                        $("input[type='checkbox']").on('click', function () {
                            var current = $(this)[0];
                            if (current.value == 0) {
                                //select or deselect all checkboxes
                                $("input[type='checkbox']").each(function (index, ctrl) {
                                    ctrl.checked = current.checked;
                                });
                            }
                            else {
                                if (current.checked) {
                                    //check if others are checked, if yes mark all textbox

                                    var allChecked = true; //set true by default. 
                                    $("input[type='checkbox']").each(function (index, ctrl) {
                                        if (index == 0)
                                            return;

                                        if (!ctrl.checked) {
                                            allChecked = false;
                                            return false;
                                        }
                                    });

                                    //tick 'all' checkbox
                                    if (allChecked)
                                        $("input[type='checkbox']")[0].checked = true;
                                    else
                                        $("input[type='checkbox']")[0].checked = false;
                                }
                                else
                                    //untick all box
                                    $("input[type='checkbox']")[0].checked = false;



                            }
                        });
                        document.getElementById("<%= ContentPanel.ClientID %>").style.height = (window.innerHeight - 150) + "px";
                    });

                    $(window).resize(function () {
                        document.getElementById("<%= ContentPanel.ClientID %>").style.height = (window.innerHeight - 150) + "px";
                    });
                </script>
            </telerik:RadScriptBlock>
        </ContentTemplate>

    </asp:UpdatePanel>

</asp:Content>
