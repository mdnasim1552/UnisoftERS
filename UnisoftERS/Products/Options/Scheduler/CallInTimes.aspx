<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Templates/Scheduler.Master" CodeBehind="CallInTimes.aspx.vb" Inherits="UnisoftERS.CallInTimes" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContentPlaceHolder" runat="server">
    <title>Call-in times</title>
    <script type="text/javascript" src="../../../Scripts/Global.js"></script>
    <script type="text/javascript" src="../../../Scripts/jquery-3.6.3.min.js"></script>
    <link type="text/css" href="../../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
    </style>
    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <script type="text/javascript">
            $(window).on('load', function () {
            });

            $(document).ready(function () {
                Sys.Application.add_load(function () {
                    bindEvents();
                });
            });

            function bindEvents() {

            }

            function editCallInTime(rowIndex) {
                var gvID = $find('<%=CallInTimesRadGrid.ClientID %>');
                var masterTableView = gvID.get_masterTableView();
                var dataItems = masterTableView.get_dataItems()[rowIndex];

                //get the datakeyname
                var procType = dataItems.getDataKeyValue("ProcedureType");
                var minutes = dataItems.getDataKeyValue("CallInMinutes");
                var id = dataItems.getDataKeyValue("CallInTimeId");

                $('#<%=ProcedureTypeLabel.ClientID%>').text(procType);
                $('#<%=CallInMinsRadTextBox.ClientID%>').val(minutes);

                var oWnd = $find('<%= AddNewItemRadWindow.ClientID%>');

                if (oWnd != null) {
                    oWnd.set_title('Edit call-in time');
                    oWnd.setSize('350', '155');
                    oWnd.show();

                    $find('<%=AddNewItemSaveRadButton.ClientID%>').set_commandArgument(id);
                }
                return false;
            }

            function closeAddItemWindow() {
                var oWnd = $find('<%= AddNewItemRadWindow.ClientID%>');
                if (oWnd != null)
                    oWnd.close();
                return false;
            }
        </script>
    </telerik:RadScriptBlock>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyContentPlaceHolder" runat="server">
    <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Metro" />
    <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />

    <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro">
    </telerik:RadAjaxLoadingPanel>

    <div class="optionsHeading">
        <asp:Label ID="HeadingLabel" runat="server" Text="Add/Edit procedure call-in times"></asp:Label>
    </div>

    <div id="FormDiv" runat="server" style="margin: 10px;">
        <div id="FilterBox" class="optionsBodyText" style="margin-left: 10px; width: 556px">
            <div style="padding-top: 10px;">
                Hospital:
                    <telerik:RadComboBox ID="HospitalsComboBox" runat="server" Skin="Metro" AutoPostBack="true" Width="270"
                        CssClass="filterDDL" />
            </div>

        </div>
        <div style="margin-left: 10px; margin-top: 20px;" class="rptText">
            <div style="margin-bottom: 5px;">
                <telerik:RadGrid ID="CallInTimesRadGrid" runat="server" DataSourceID="CallInTimesSQLDataSource" AutoGenerateColumns="false"
                    AllowMultiRowSelection="false" AllowSorting="true" Skin="Metro" PageSize="25" AllowPaging="true" Style="margin-bottom: 10px; width: 50%; height: 500px;"
                    OnItemCreated="CallInTimesRadGrid_ItemCreated">
                    <HeaderStyle Font-Bold="true" />
                    <MasterTableView ShowHeadersWhenNoRecords="true" TableLayout="Fixed" EnableNoRecordsTemplate="true" CssClass="MasterClass"
                        ClientDataKeyNames="ProcedureTypeId,CallInMinutes,ProcedureType,CallInTimeId">
                        <Columns>
                            <telerik:GridTemplateColumn UniqueName="TemplateColumn" HeaderStyle-Width="25px">
                                <ItemTemplate>
                                    <asp:LinkButton ID="EditLinkButton" runat="server" Text="Edit" ToolTip="Edit this item" Font-Italic="true"></asp:LinkButton>
                                    &nbsp;&nbsp;
                                </ItemTemplate>
                            </telerik:GridTemplateColumn>
                            <telerik:GridBoundColumn DataField="ProcedureType" HeaderText="Procedure Type" SortExpression="ProcedureType"
                                HeaderStyle-Width="40px" AllowSorting="true" ShowSortIcon="true" />
                            <telerik:GridBoundColumn DataField="CallInMinutes" HeaderText="Call-in Time (mins)" SortExpression="CallInMinutes"
                                HeaderStyle-Width="14px" ItemStyle-Wrap="true" />
                        </Columns>
                        <NoRecordsTemplate>
                            <div style="margin-top: 10px; margin-bottom: 10px; margin-left: 5px;" id="NoRecordsDiv" runat="server">
                                No call-in times found.
                            </div>
                        </NoRecordsTemplate>
                    </MasterTableView>
                    <ClientSettings>
                        <Scrolling AllowScroll="true" UseStaticHeaders="true" />
                    </ClientSettings>
                </telerik:RadGrid>
            </div>
        </div>
    </div>
    <telerik:RadWindowManager ID="RadWindowManager1" runat="server" Skin="Metro" Modal="true" VisibleStatusbar="false">
        <Windows>
            <telerik:RadWindow ID="AddNewItemRadWindow" runat="server" ReloadOnShow="true" Title="New Mapping"
                KeepInScreenBounds="true" Skin="Metro">
                <ContentTemplate>
                    <telerik:RadFormDecorator ID="WindowFormDecorator2" runat="server" DecorationZoneID="AddEditMappingsDiv2"
                        Skin="Metro" DecoratedControls="All" />
                    <div id="AddEditCallInTimes" style="margin-top:15px;">
                        <table cellspacing="3" cellpadding="3" style="width:100%;">
                            <tr>
                                <td style="text-align:right;">
                                    <span>Call-in time for </span><asp:Label ID="ProcedureTypeLabel" runat="server" Font-Underline="true" />:
                                </td>
                                <td>
                                    <telerik:RadNumericTextBox ID="CallInMinsRadTextBox" runat="server"
                                        IncrementSettings-InterceptMouseWheel="false"
                                        IncrementSettings-Step="1"
                                        Width="45px"
                                        MinValue="0" MaxValue="1000" Style="margin-right: 3px;">
                                        <NumberFormat DecimalDigits="0" />
                                    </telerik:RadNumericTextBox>minutes
                                </td>
                            </tr>
                        </table>
                        <div id="buttonsdiv2" style="height: 10px; padding-top: 15px; text-align: center;">
                            <telerik:RadButton ID="AddNewItemSaveRadButton" runat="server" Text="Save" Skin="Metro" OnClick="AddNewItemSaveRadButton_Click" />
                            <telerik:RadButton ID="AddNewItemCancelRadButton" runat="server" Text="Cancel" Skin="Metro" OnClientClicked="closeAddItemWindow" />
                        </div>
                    </div>
                </ContentTemplate>
            </telerik:RadWindow>
        </Windows>
    </telerik:RadWindowManager>

    <asp:SqlDataSource ID="CallInTimesSQLDataSource" runat="server"
        SelectCommand="sch_callintimes_select"
        SelectCommandType="StoredProcedure"
        UpdateCommand="sch_callintimes_update"
        UpdateCommandType="StoredProcedure">
        <SelectParameters>
            <asp:ControlParameter Name="OperatingHospitalId" DbType="String" ControlID="HospitalsComboBox" PropertyName="SelectedValue" />
        </SelectParameters>
        <UpdateParameters>
            <asp:Parameter Name="CallInTimeId" Type="Int32" />
            <asp:Parameter Name="CallInMinutes" Type="Int32" />
        </UpdateParameters>
    </asp:SqlDataSource>
    <asp:ObjectDataSource ID="CallIntimesObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch"
        SelectMethod="GetProcedureCallInTimes">
        <SelectParameters>
            <asp:ControlParameter Name="OperatingHospitalId" DbType="String" ControlID="HospitalsComboBox" PropertyName="SelectedValue" />
        </SelectParameters>
    </asp:ObjectDataSource>
</asp:Content>
