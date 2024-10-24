<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="PointMappings.aspx.vb" Inherits="UnisoftERS.PointMappings" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Add/Edit Point Mainute Mappings</title>
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

            function addNonGIProcedureMapping() {
                //debugger;
                $('#<%=PointsMappingIDHiddenFieldNonGI.ClientID%>').val('');
                $('#<%=DiagnosticMinutesRadTextBoxNonGI.ClientID%>').val("15");
                $('#<%=DiagnosticPointsRadTextBoxNonGI.ClientID%>').val("1");
                $('#<%=ProcedureTypeLabelNonGI.ClientID%>').text("other procedure");
                $('#<%=NonGIProcedureTypeRadTextBox.ClientID%>').val('');

                $('.non-gi-procedure-tr').show();

                var oWnd = $find("<%= AddNewItemRadWindowNonGI.ClientID%>");
                if (oWnd != null) {
                    oWnd.set_title('Add Mapping');
                    oWnd.setSize("300", "225")
                    oWnd.show();

                    $find("<%=AddNewItemSaveRadButtonNonGI.ClientID%>").set_commandName("saveNonGIMappings");

                }
                return false;
            }

            function editMapping(PointsMappingId, ProcedureType, DiagMinutes, DiagPoints, TheraMinutes, TheraPoints) {

                if (ProcedureType != 'ERCP') {
                    $('#<%=PointsMappingIDHiddenField.ClientID%>').val(PointsMappingId);
                    $('#<%=DiagnosticMinutesRadTextBox.ClientID%>').val(DiagMinutes);
                    $('#<%=DiagnosticPointsRadTextBox.ClientID%>').val(DiagPoints);
                    $('#<%=TherapeuticMinutesRadTextBox.ClientID%>').val(TheraMinutes);
                    $('#<%=TherapeuticPointsRadTextBox.ClientID%>').val(TheraPoints);
                    $('#<%=ProcedureTypeLabel.ClientID%>').text(ProcedureType);
                }
                else {
                    $('#<%=PointsMappingIDHiddenField.ClientID%>').val(PointsMappingId);
                    $('#<%=TherapeuticMinutesRadTextBox.ClientID%>').val(TheraMinutes);
                    $('#<%=TherapeuticPointsRadTextBox.ClientID%>').val(TheraPoints);
                    $('#<%=ProcedureTypeLabel.ClientID%>').text(ProcedureType);

                    $('#DiagPointsLabel').hide();
                    $('#DiagPoints').hide();
                    $('#DiagMinutesLabel').hide();
                    $('#DiagMinutes').hide();
                }

                var oWnd = $find('<%= AddNewItemRadWindow.ClientID%>');
                if (oWnd != null) {
                    oWnd.set_title('Edit Mapping');
                    oWnd.setSize('300', '225');
                    oWnd.show();

                    $find('<%=AddNewItemSaveRadButton.ClientID%>').set_commandName('saveGIMappings');
                }

                return false;
            }

            function Show() {
                if (confirm("Are you sure you want to suppress this mapping?")) {
                    return true;
                }
                else {
                    return false;
                }
            }

            function editMappingTraining(PointsMappingId, ProcedureType, DiagMinutes, DiagPoints, TheraMinutes, TheraPoints) {

                //$('.non-gi-procedure-tr').hide();
                if (ProcedureType != 'ERCP') {
                    $('#<%=PointsMappingIDHiddenField.ClientID%>').val(PointsMappingId);
                    $('#<%=DiagnosticMinutesRadTextBox.ClientID%>').val(DiagMinutes);
                    $('#<%=DiagnosticPointsRadTextBox.ClientID%>').val(DiagPoints);
                    $('#<%=TherapeuticMinutesRadTextBox.ClientID%>').val(TheraMinutes);
                    $('#<%=TherapeuticPointsRadTextBox.ClientID%>').val(TheraPoints);
                    $('#<%=ProcedureTypeLabel.ClientID%>').text(ProcedureType);
                }
                else {
                    $('#<%=PointsMappingIDHiddenField.ClientID%>').val(PointsMappingId);
                    $('#<%=TherapeuticMinutesRadTextBox.ClientID%>').val(TheraMinutes);
                    $('#<%=TherapeuticPointsRadTextBox.ClientID%>').val(TheraPoints);
                    $('#<%=ProcedureTypeLabel.ClientID%>').text(ProcedureType);

                    $('#DiagPointsLabel').hide();
                    $('#DiagPoints').hide();
                    $('#DiagMinutesLabel').hide();
                    $('#DiagMinutes').hide();
                }

                var oWnd = $find('<%= AddNewItemRadWindow.ClientID%>');
                if (oWnd != null) {
                    oWnd.set_title('Edit Mapping');
                    oWnd.setSize('300', '225');
                    oWnd.show();

                    $find('<%=AddNewItemSaveRadButton.ClientID%>').set_commandName('saveGIMappingsTraining');
                }
                return false;
            }

            function editMappingNonGI(PointsMappingId, ProcedureType, DiagMinutes, DiagPoints) {

                $('#<%=PointsMappingIDHiddenFieldNonGI.ClientID%>').val(PointsMappingId);
                $('#<%=DiagnosticMinutesRadTextBoxNonGI.ClientID%>').val(DiagMinutes);
                $('#<%=DiagnosticPointsRadTextBoxNonGI.ClientID%>').val(DiagPoints);
                $('#<%=ProcedureTypeLabelNonGI.ClientID%>').text('other procedure');
                $('#<%=NonGIProcedureTypeRadTextBox.ClientID%>').val(ProcedureType);

                var oWnd = $find('<%= AddNewItemRadWindowNonGI.ClientID%>');

                if (oWnd != null) {
                    oWnd.set_title('Edit Mapping');
                    oWnd.setSize('300', '225');
                    oWnd.show();

                    $find('<%=AddNewItemSaveRadButtonNonGI.ClientID%>').set_commandName('saveNonGIMappings');
                }
                return false;
            }

            function Show() {
                if (confirm("Are you sure you want to suppress this mapping?")) {
                    return true;
                }
                else {
                    return false;
                }
            }

            function closeAddItemWindow() {
                var oWnd = $find('<%= AddNewItemRadWindow.ClientID%>');
                if (oWnd != null)
                    oWnd.close();
                return false;
            }

            function closeAddItemWindowNonGI() {
                var oWnd = $find('<%= AddNewItemRadWindowNonGI.ClientID%>');
                if (oWnd != null)
                    oWnd.close();

                //Blank out fields here for Non-GI
                <%--$('#<%=PointsMappingIDHiddenFieldNonGI.ClientID%>').val('');
                $('#<%=DiagnosticMinutesRadTextBoxNonGI.ClientID%>').val('');
                $('#<%=DiagnosticPointsRadTextBoxNonGI.ClientID%>').val('');
                $('#<%=NonGIProcedureTypeRadTextBox.ClientID%>').val('');--%>

                return false;
            }

            function OnClientClose() {
                <%--var NonGIMinutesTextBox = $find('<%=DiagnosticMinutesRadTextBoxNonGI.ClientID %>');
                var NonGIPointsTextBox = $find('<%=DiagnosticPointsRadTextBoxNonGI.ClientID %>');
                var NonGIProcedureTextBox = $find('<%=NonGIProcedureTypeRadTextBox.ClientID %>');
                NonGIMinutesTextBox.clear();
                NonGIPointsTextBox.clear();
                NonGIProcedureTextBox.clear();--%>
            }

        </script>
    </telerik:RadScriptBlock>
</head>

<body>
    <form id="form1" runat="server">
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />

        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Metro" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
         <telerik:RadAjaxManager ID="myAjaxMgr" runat="server" />

        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro">
        </telerik:RadAjaxLoadingPanel>

        <div class="optionsHeading">
            <asp:Label ID="HeadingLabel" runat="server" Text="Add/Edit Point to Minute Mappings"></asp:Label>
        </div>

        <div id="FormDiv" runat="server" style="margin: 10px;">
            <div id="FilterBox" class="optionsBodyText" style="margin-left: 10px; width: 556px">
                <div style="padding-top: 10px;">
                    Hospital:
                    <telerik:RadComboBox ID="HospitalsComboBox" runat="server" Skin="Metro" AutoPostBack="true" Width="270"
                        CssClass="filterDDL" OnSelectedIndexChanged="HospitalsComboBox_SelectedIndexChanged" />
                </div>

            </div>
        </div>

        <div style="margin-left: 10px; margin-top: 20px;" class="rptText">
            <div style="margin-bottom: 5px;">

                <telerik:RadTabStrip ID="RadTabStrip1" runat="server" MultiPageID="RadMultiPage1" SelectedIndex="0" Skin="Metro"
                    RenderMode="Lightweight">
                    <Tabs>
                        <telerik:RadTab Text="Endoscopic Procedures" Value="1" Font-Bold="false" Selected="true" PageViewID="RadPageView1"
                            Style="text-align: center;" />
                        <telerik:RadTab Text="Training" Value="2" Font-Bold="false" PageViewID="RadPageView2" Selected="false" />
                    </Tabs>
                </telerik:RadTabStrip>

                <telerik:RadMultiPage ID="RadMultiPage1" runat="server">
                    <telerik:RadPageView ID="RadPageView1" runat="server" Selected="true">
                        <div style="padding: 10px;">
                            <div style="padding-bottom: 10px;">
                                <span>Default value for non-reserved slots:</span>&nbsp;
                            <telerik:RadNumericTextBox ID="DefaultSlotLengthRadNumericTextBox" runat="server" Width="40"
                                DecimalDigits="0"
                                NumberFormat-DecimalDigits="0" />
                                <telerik:RadButton ID="SaveDefaultSlotLengthRadButton" runat="server" Text="Update" />
                            </div>
                            <telerik:RadGrid ID="PointMappingsRadGrid" runat="server" OnItemDataBound="PointMappingsRadGrid_ItemDataBound"
                                OnItemCreated="PointMappingsRadGrid_ItemCreated" DataSourceID="PointMappingsObjectDataSource" AutoGenerateColumns="false"
                                AllowMultiRowSelection="false"
                                AllowSorting="true"
                                Skin="Metro" PageSize="25" AllowPaging="true" Style="margin-bottom: 10px; width: 50%; height: 500px;">
                                <HeaderStyle Font-Bold="true" />
                                <MasterTableView ShowHeadersWhenNoRecords="true" ClientDataKeyNames="PointsMappingId,ProcedureType,DiagnosticMinutes,DiagnosticPoints,TherapeuticMinutes,TherapeuticPoints"
                                    DataKeyNames="PointsMappingId,ProcedureType,DiagnosticMinutes,DiagnosticPoints,TherapeuticMinutes,TherapeuticPoints"
                                    TableLayout="Fixed" EnableNoRecordsTemplate="true" CssClass="MasterClass">
                                    <Columns>
                                        <telerik:GridTemplateColumn UniqueName="TemplateColumn" HeaderStyle-Width="25px">
                                            <ItemTemplate>
                                                <asp:LinkButton ID="EditLinkButton" runat="server" Text="Edit" ToolTip="Edit this item" Font-Italic="true"></asp:LinkButton>
                                                &nbsp;&nbsp;
                                            </ItemTemplate>
                                        </telerik:GridTemplateColumn>
                                        <telerik:GridBoundColumn DataField="ProcedureType" HeaderText="Procedure Type" SortExpression="ProcedureType"
                                            HeaderStyle-Width="40px" AllowSorting="true" ShowSortIcon="true" />
                                        <telerik:GridTemplateColumn HeaderText="Diagnostic Points" HeaderStyle-Width="14px">
                                            <ItemTemplate>
                                                <asp:Label ID="GridDiagnosticPointsLabel" runat="server" Text='<%#Bind("DiagnosticPoints") %>' />
                                            </ItemTemplate>
                                        </telerik:GridTemplateColumn>
                                        <telerik:GridTemplateColumn HeaderText="Diagnostic Minutes" HeaderStyle-Width="14px">
                                            <ItemTemplate>
                                                <asp:Label ID="GridDiagnosticMinutesLabel" runat="server" Text='<%#Bind("DiagnosticMinutes") %>' />
                                            </ItemTemplate>
                                        </telerik:GridTemplateColumn>
                                        <%--<telerik:GridBoundColumn DataField="DiagnosticMinutes" HeaderText="Diagnostic Minutes" SortExpression="DiagnosticMinutes"
                                        HeaderStyle-Width="14px" ItemStyle-Wrap="true" />--%>
                                        <telerik:GridTemplateColumn HeaderText="Therapeutic Points" HeaderStyle-Width="14px">
                                            <ItemTemplate>
                                                <asp:Label ID="GridTherapeuticPointsLabel" runat="server" Text='<%#Bind("TherapeuticPoints") %>' />
                                            </ItemTemplate>
                                        </telerik:GridTemplateColumn>
                                        <telerik:GridBoundColumn DataField="TherapeuticMinutes" HeaderText="Therapeutic Minutes" SortExpression="TherapeuticMinutes"
                                            HeaderStyle-Width="14px" ItemStyle-Wrap="true" />
                                    </Columns>
                                    <NoRecordsTemplate>
                                        <div style="margin-top: 10px; margin-bottom: 10px; margin-left: 5px;" id="NoRecordsDiv" runat="server">
                                            No mappings found.
                                        </div>
                                    </NoRecordsTemplate>
                                </MasterTableView>
                                <ClientSettings>
                                    <Scrolling AllowScroll="true" UseStaticHeaders="true" />
                                </ClientSettings>
                            </telerik:RadGrid>
                        </div>
                    </telerik:RadPageView>

                    <telerik:RadPageView ID="RadPageView2" runat="server">
                        <div style="padding: 10px;">
                            <div style="padding-bottom: 10px;">

                                <span>Default value for non-reserved slots (training):</span>&nbsp;
                            <telerik:RadNumericTextBox ID="DefaultTrainingSlotLengthRadNumericTextBox" runat="server" Width="40"
                                DecimalDigits="0"
                                NumberFormat-DecimalDigits="0"/>
                                <telerik:RadButton ID="SaveDefaultTrainingSlotLengthRadButton" runat="server" Text="Update" />
                            </div>
                            <telerik:RadGrid ID="TrainingPointMappingsRadGrid" runat="server" OnItemDataBound="PointMappingsRadGrid_ItemDataBound"
                                OnItemCreated="TrainingPointMappingsRadGrid_ItemCreated" DataSourceID="TrainingPointMappingsObjectDataSource"
                                AutoGenerateColumns="false" AllowMultiRowSelection="false"
                                AllowSorting="true"
                                Skin="Metro" PageSize="25" AllowPaging="true" Style="margin-bottom: 10px; width: 50%; height: 500px;">
                                <HeaderStyle Font-Bold="true" />
                                <MasterTableView ShowHeadersWhenNoRecords="true" ClientDataKeyNames="PointsMappingId,ProcedureType,DiagnosticMinutes,DiagnosticPoints,TherapeuticMinutes,TherapeuticPoints"
                                    DataKeyNames="PointsMappingId,ProcedureType,DiagnosticMinutes,DiagnosticPoints,TherapeuticMinutes,TherapeuticPoints"
                                    TableLayout="Fixed" EnableNoRecordsTemplate="true" CssClass="MasterClass">
                                    <Columns>
                                        <telerik:GridTemplateColumn UniqueName="TemplateColumn" HeaderStyle-Width="25px">
                                            <ItemTemplate>
                                                <asp:LinkButton ID="EditLinkButton" runat="server" Text="Edit" ToolTip="Edit this item" Font-Italic="true"></asp:LinkButton>
                                                &nbsp;&nbsp;
                                            </ItemTemplate>
                                        </telerik:GridTemplateColumn>
                                        <telerik:GridBoundColumn DataField="ProcedureType" HeaderText="Procedure Type" SortExpression="ProcedureType"
                                            HeaderStyle-Width="40px" AllowSorting="true" ShowSortIcon="true" />
                                        <telerik:GridTemplateColumn HeaderText="Diagnostic Points" HeaderStyle-Width="14px">
                                            <ItemTemplate>
                                                <asp:Label ID="GridDiagnosticPointsLabel" runat="server" Text='<%#Bind("DiagnosticPoints") %>' />
                                            </ItemTemplate>
                                        </telerik:GridTemplateColumn>
                                        <telerik:GridTemplateColumn HeaderText="Diagnostic Minutes" HeaderStyle-Width="14px">
                                            <ItemTemplate>
                                                <asp:Label ID="GridDiagnosticMinutesLabel" runat="server" Text='<%#Bind("DiagnosticMinutes") %>' />
                                            </ItemTemplate>
                                        </telerik:GridTemplateColumn>
                                        <%--<telerik:GridBoundColumn DataField="DiagnosticMinutes" HeaderText="Diagnostic Minutes" SortExpression="DiagnosticMinutes"
                                        HeaderStyle-Width="14px" ItemStyle-Wrap="true" />--%>
                                        <telerik:GridTemplateColumn HeaderText="Therapeutic Points" HeaderStyle-Width="14px">
                                            <ItemTemplate>
                                                <asp:Label ID="GridTherapeuticPointsLabel" runat="server" Text='<%#Bind("TherapeuticPoints") %>' />
                                            </ItemTemplate>
                                        </telerik:GridTemplateColumn>
                                        <telerik:GridBoundColumn DataField="TherapeuticMinutes" HeaderText="Therapeutic Minutes" SortExpression="TherapeuticMinutes"
                                            HeaderStyle-Width="14px" ItemStyle-Wrap="true" />
                                    </Columns>
                                    <NoRecordsTemplate>
                                        <div style="margin-top: 10px; margin-bottom: 10px; margin-left: 5px;" id="NoRecordsDiv" runat="server">
                                            No mappings found.
                                        </div>
                                    </NoRecordsTemplate>
                                </MasterTableView>
                                <PagerStyle  Mode="NextPrev" PagerTextFormat="Navigate Pages {4} Page {0} of {1}; Patients {2} to {3} of {5}"
                                    AlwaysVisible="false" />
                                <ClientSettings>
                                    <Scrolling AllowScroll="true" UseStaticHeaders="true" />
                                </ClientSettings>
                            </telerik:RadGrid>
                        </div>
                    </telerik:RadPageView>

                    <telerik:RadPageView ID="RadPageView3" runat="server">
                        <div style="padding: 10px;">
                            <div style="padding-bottom: 10px;">

                                <span>Default value for non-reserved slots (other procedures):</span>&nbsp;
                            <telerik:RadNumericTextBox ID="DefaultNonGISlotLengthRadNumericTextBox" runat="server" Width="40"
                                DecimalDigits="0"
                                NumberFormat-DecimalDigits="0" />
                                <telerik:RadButton ID="SaveDefaultNonGISlotLengthRadButton" runat="server" Text="Update" />
                            </div>
                            <telerik:RadGrid ID="NonGIPointMappingsRadGrid" runat="server" OnItemDataBound="NonGIPointMappingsRadGrid_ItemDataBound"
                                DataSourceID="NonGIPointMappingsObjectDataSource" OnItemCreated="NonGIPointMappingsRadGrid_ItemCreated"
                                AutoGenerateColumns="false" AllowMultiRowSelection="false" AllowSorting="true"
                                Skin="Metro" PageSize="25" AllowPaging="true" Style="margin-bottom: 10px; width: 50%; height: 500px;">
                                <HeaderStyle Font-Bold="true" />
                                <MasterTableView ShowHeadersWhenNoRecords="true" ClientDataKeyNames="PointsMappingId,ProcedureType,DiagnosticMinutes,DiagnosticPoints"
                                    DataKeyNames="PointsMappingId,ProcedureType,DiagnosticMinutes,DiagnosticPoints"
                                    TableLayout="Fixed" EnableNoRecordsTemplate="true" CssClass="MasterClass">
                                    <Columns>
                                        <telerik:GridTemplateColumn UniqueName="TemplateColumn" HeaderStyle-Width="25px">
                                            <HeaderTemplate>
                                                <telerik:RadButton ID="AddNewMappingsButton" runat="server" Text="Add New mappings" Skin="Metro" AutoPostBack="false"
                                                    OnClientClicked="addNonGIProcedureMapping" />
                                            </HeaderTemplate>
                                            <ItemTemplate>
                                                <asp:LinkButton ID="EditLinkButton" runat="server" Text="Edit" ToolTip="Edit this item" Font-Italic="true"></asp:LinkButton>
                                                &nbsp;&nbsp;
                                            </ItemTemplate>
                                        </telerik:GridTemplateColumn>
                                        <telerik:GridBoundColumn DataField="ProcedureType" HeaderText="Procedure Type" SortExpression="ProcedureType"
                                            HeaderStyle-Width="40px" AllowSorting="true" ShowSortIcon="true" />
                                        <telerik:GridTemplateColumn HeaderText="Diagnostic Points" HeaderStyle-Width="20px">
                                            <ItemTemplate>
                                                <asp:Label ID="GridDiagnosticPointsLabel" runat="server" Text='<%#Bind("DiagnosticPoints") %>' />
                                            </ItemTemplate>
                                        </telerik:GridTemplateColumn>
                                        <telerik:GridBoundColumn DataField="DiagnosticMinutes" HeaderText="Diagnostic Minutes" SortExpression="DiagnosticMinutes"
                                            HeaderStyle-Width="20px" ItemStyle-Wrap="true" />
                                    </Columns>
                                    <NoRecordsTemplate>
                                        <div style="margin-top: 10px; margin-bottom: 10px; margin-left: 5px;" id="NoRecordsDiv" runat="server">
                                            No mappings found.
                                        </div>
                                    </NoRecordsTemplate>
                                </MasterTableView>
                                <PagerStyle Mode="NextPrev" PagerTextFormat="Navigate Pages {4} Page {0} of {1}; Procedures {2} to {3} of {5}"
                                    AlwaysVisible="false" />
                                <ClientSettings>
                                    <Scrolling AllowScroll="true" UseStaticHeaders="true" />
                                </ClientSettings>
                            </telerik:RadGrid>
                        </div>
                    </telerik:RadPageView>
                </telerik:RadMultiPage>
            </div>
        </div>
        <telerik:RadWindowManager ID="RadWindowManager1" runat="server" Skin="Metro" Modal="true" VisibleStatusbar="false">
            <Windows>
                <telerik:RadWindow ID="AddNewItemRadWindow" runat="server" ReloadOnShow="true" Title="New Mapping"
                    KeepInScreenBounds="true" Width="400" Height="180" Skin="Metro">
                    <ContentTemplate>
                        <telerik:RadFormDecorator ID="WindowFormDecorator" runat="server" DecorationZoneID="AddEditMappingsDiv"
                            Skin="Metro" DecoratedControls="All" />
                        <div id="AddEditMappingsDiv">
                            <asp:HiddenField ID="PointsMappingIDHiddenField" runat="server" />
                            <div style="margin-top: 15px; margin-left: 6px; margin-bottom: 10px; font-weight: bold; text-align: center">
                                Point mappings for&nbsp;<asp:Label ID="ProcedureTypeLabel" runat="server" />
                            </div>
                            <table cellspacing="3" cellpadding="3">
                                <%--<tr class="non-gi-procedure-tr">
                                <td>Procedure:
                                </td>
                                <td>
                                    <telerik:RadTextBox ID="NonGIProcedureTypeRadTextBox" runat="server" />
                                </td>
                            </tr>--%>
                                <tr>
                                    <td id="DiagPointsLabel">Diagnostic Points:</td>
                                    <td id="DiagPoints"> <%--Added by rony tfs-4065--%>
                                        <telerik:RadNumericTextBox ID="DiagnosticPointsRadTextBox" runat="server"
                                            IncrementSettings-InterceptMouseWheel="false"
                                            IncrementSettings-Step="0.5"
                                            Width="45px"
                                            MinValue="1"
                                            MaxValue="24">
                                            <NumberFormat DecimalDigits="2" />
                                        </telerik:RadNumericTextBox>
                                    </td>
                                    <td>Therapeutic Points:</td>
                                    <td>
                                        <telerik:RadNumericTextBox ID="TherapeuticPointsRadTextBox" runat="server"
                                            IncrementSettings-InterceptMouseWheel="false"
                                            IncrementSettings-Step="0.5"
                                            Width="45px"
                                            MinValue="0">
                                            <NumberFormat DecimalDigits="2" />
                                        </telerik:RadNumericTextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td id="DiagMinutesLabel" valign="top">Diagnostic Minutes:</td>
                                    <td id="DiagMinutes">
                                        <telerik:RadNumericTextBox ID="DiagnosticMinutesRadTextBox" runat="server"
                                            IncrementSettings-InterceptMouseWheel="false"
                                            IncrementSettings-Step="1"
                                            Width="45px"
                                            MinValue="1">
                                            <NumberFormat DecimalDigits="0" />
                                        </telerik:RadNumericTextBox>
                                    </td>
                                    <td valign="top">Therapeutic Minutes:</td>
                                    <td>
                                        <telerik:RadNumericTextBox ID="TherapeuticMinutesRadTextBox" runat="server"
                                            IncrementSettings-InterceptMouseWheel="false"
                                            IncrementSettings-Step="1"
                                            Width="45px"
                                            MinValue="1">
                                            <NumberFormat DecimalDigits="0" />
                                        </telerik:RadNumericTextBox>
                                    </td>
                                </tr>
                            </table>
                            &nbsp;
                        <div id="buttonsdiv" style="height: 10px; padding-top: 6px; text-align: center;">
                            <telerik:RadButton ID="AddNewItemSaveRadButton" runat="server" Text="Save" Skin="Metro" OnClick="AddNewItemSaveRadButton_Click" />
                            <telerik:RadButton ID="AddNewItemCancelRadButton" runat="server" Text="Cancel" Skin="Metro" OnClientClicked="closeAddItemWindow" />
                        </div>
                        </div>
                    </ContentTemplate>
                </telerik:RadWindow>

                <telerik:RadWindow ID="AddNewItemRadWindowNonGI" runat="server" ReloadOnShow="true" Title="New Mapping"
                    KeepInScreenBounds="true" Width="250" Height="225" Skin="Metro">
                    <ContentTemplate>
                        <telerik:RadFormDecorator ID="WindowFormDecorator2" runat="server" DecorationZoneID="AddEditMappingsDiv2"
                            Skin="Metro" DecoratedControls="All" />
                        <div id="AddEditMappingsDiv2">
                            <asp:HiddenField ID="PointsMappingIDHiddenFieldNonGI" runat="server" />
                            <div style="margin-top: 15px; margin-left: 6px; margin-bottom: 10px; font-weight: bold; text-align: center">
                                Point mappings for&nbsp;<asp:Label ID="ProcedureTypeLabelNonGI" runat="server" />
                            </div>
                            <table cellspacing="3" cellpadding="3">
                                <tr class="non-gi-procedure-tr">
                                    <td>Procedure:
                                    </td>
                                    <td>
                                        <asp:TextBox ID="NonGIProcedureTypeRadTextBox" runat="server" />
                                    </td>
                                </tr>
                                <tr>
                                    <td valign="top">Diagnostic Points:</td>
                                    <td>
                                        <telerik:RadNumericTextBox ID="DiagnosticPointsRadTextBoxNonGI" runat="server"
                                            IncrementSettings-InterceptMouseWheel="false"
                                            IncrementSettings-Step="0.25"
                                            Width="45px"
                                            MinValue="0">
                                            <NumberFormat DecimalDigits="2" />
                                        </telerik:RadNumericTextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td valign="top">Diagnostic Minutes:</td>
                                    <td>
                                        <telerik:RadNumericTextBox ID="DiagnosticMinutesRadTextBoxNonGI" runat="server"
                                            IncrementSettings-InterceptMouseWheel="false"
                                            IncrementSettings-Step="1"
                                            Width="45px"
                                            MinValue="1">
                                            <NumberFormat DecimalDigits="0" />
                                        </telerik:RadNumericTextBox>
                                    </td>
                                </tr>
                            </table>
                            <div id="buttonsdiv2" style="height: 10px; padding-top: 6px; text-align: center;">
                                <telerik:RadButton ID="AddNewItemSaveRadButtonNonGI" runat="server" Text="Save" Skin="Metro" OnClick="AddNewItemSaveRadButton_Click" />
                                <telerik:RadButton ID="AddNewItemCancelRadButtonNonGI" runat="server" Text="Cancel" Skin="Metro" OnClientClicked="closeAddItemWindowNonGI" />
                            </div>
                        </div>
                    </ContentTemplate>
                </telerik:RadWindow>

            </Windows>
        </telerik:RadWindowManager>

        <asp:ObjectDataSource ID="PointMappingsObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch"
            SelectMethod="GetPointMappings">
            <SelectParameters>
                <asp:ControlParameter Name="OperatingHospitalId" DbType="String" ControlID="HospitalsComboBox" PropertyName="SelectedValue" />
                <asp:Parameter Name="isTraining" Type="Boolean" DefaultValue="false" />
                <asp:Parameter Name="isNonGI" Type="Boolean" DefaultValue="false" />
            </SelectParameters>
        </asp:ObjectDataSource>

        <asp:ObjectDataSource ID="TrainingPointMappingsObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch"
            SelectMethod="GetPointMappings">
            <SelectParameters>
                <asp:ControlParameter Name="OperatingHospitalId" DbType="String" ControlID="HospitalsComboBox" PropertyName="SelectedValue" />
                <asp:Parameter Name="isTraining" Type="Boolean" DefaultValue="true" />
                <asp:Parameter Name="isNonGI" Type="Boolean" DefaultValue="false" />
            </SelectParameters>
        </asp:ObjectDataSource>

        <asp:ObjectDataSource ID="NonGIPointMappingsObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch"
            SelectMethod="GetPointMappings">
            <SelectParameters>
                <asp:ControlParameter Name="OperatingHospitalId" DbType="String" ControlID="HospitalsComboBox" PropertyName="SelectedValue" />
                <asp:Parameter Name="isTraining" Type="Boolean" DefaultValue="false" />
                <asp:Parameter Name="isNonGI" Type="Boolean" DefaultValue="true" />
            </SelectParameters>
        </asp:ObjectDataSource>
    </form>
</body>
</html>
