<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Options_Scheduler_EditTemplates" CodeBehind="EditTemplates.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head runat="server">
    <title>List template details</title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../Scripts/Global.js"></script>
    <script type="text/javascript" src="../../../Scripts/rgbcolor.js"></script>

    <link type="text/css" href="../../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
        .FormatRBL label {
            margin-right: 10px;
        }

        .RadGrid .rgSelectedRow {
            background-color: #25A0DA !important;
        }

        .slot-point td:first-child {
            padding-left: 8px;
        }

        .slot-point {
            height: 30px;
        }

            .slot-point td {
                background-color: darkgrey;
                padding-top: 4px;
                padding-bottom: 3px;
                color: darkgray !important;
            }

                .slot-point td:first-child {
                    width: 0px !important;
                }
    </style>

    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <script type="text/javascript">
            $(window).on('load', function () {
            });

            $(document).ready(function () {
                Sys.Application.add_load(function () {
                    setGridColors();
                    bindEvents();
                });
            });

            var iIndexVal; //used throughout whereever an each loop used that calls an ajax function
            function setGridColors() {
                var grid = $find("<%=SlotsRadGrid.ClientID %>");
                var MasterTable = grid.get_masterTableView();
                if (MasterTable) {
                    $(MasterTable.get_dataItems()).each(function (index, item) {

                        var comboBox = $(item.get_element()).find('.slot-combo-box');
                        if (comboBox != null && comboBox.length > 0) {
                            var slotValue = $find($(comboBox).attr("id")).get_text();
                            var gridItem = $find($(comboBox).attr("id")).findItemByText(slotValue);
                            var backColor = $($(gridItem)[0].get_element()).css("backgroundColor");

                            var tr = $(comboBox).closest('tr');
                            if (tr) {
                                $(tr).css("background-color", backColor);
                            }
                        }
                    });
                }

                grid.clearSelectedItems();

            }

            function showAddNewWindow(sender, args) {
                var oWnd = $find("<%= NewSlotRadWindow.ClientID%>");
                if (oWnd != null) {

                    $find('<%=SlotComboBox.ClientID%>').get_items().getItem(0).select();
                    $find('<%=ProcedureTypesComboBox.ClientID%>').get_items().getItem(0).select();
                    $find('<%=PointsRadNumericTextBox.ClientID%>').set_value(1);

                    //Mahfuz changed on 10 Oct 2021
                    //alert(<%=intDefaultSlothLengthMinutes%>);
                    $find('<%=SlotLengthRadNumericTextBox.ClientID%>').set_value(<%=intDefaultSlothLengthMinutes%>);
                    $find('<%=SlotQtyRadNumericTextBox.ClientID%>').set_value(1);

                    oWnd.show();

                }
            }

            function closeAddNewWindow() {
                var oWnd = $find("<%= NewSlotRadWindow.ClientID%>");
                if (oWnd != null) {
                    oWnd.close();
                }
            }

            function bindEvents() {
                $('.slot-combo-box').on('change', function () { slotEvent(this) });
                $('.procedure-type-combo-box').on('change', function () { procedureTypeEvent(this) });

               <%-- $('#<%=GIProcedureRBL.ClientID%> input').on('change', function () {
                    //check if grid has any procecedure types set
                    var canContinue = true;
                    var hasProcedures = false;
                    $('.procedure-type-combo-box').each(function (idx, itm) {
                        if ($(itm).val() != "") {
                            hasProcedures = true;
                        }
                    });

                    if (hasProcedures) {
                        if (!confirm('Changing the template type will loose any procedures already set. Continue?')) {
                            canContinue = false;
                        }
                    }

                    if (canContinue) {
                        $find('<%=RadAjaxManager1.ClientID%>').ajaxRequest('changeGIType');
                    }
                    else {
                        if ($(this).val() == "1") {
                            $('#<%=GIProcedureRBL.ClientID %>').find("input[value='0']").prop("checked", true);
                            $('#<%=GIProcedureRBL.ClientID %>').find("input[value='1']").prop("checked", false);
                        }
                        else {
                            $('#<%=GIProcedureRBL.ClientID %>').find("input[value='0']").prop("checked", false);
                            $('#<%=GIProcedureRBL.ClientID %>').find("input[value='1']").prop("checked", true);
                        }
                    }
                });--%>
            }

            function GITypeChangeCheckAndNotify(ctrl) {
             //check if grid has any procecedure types set
                    var canContinue = true;
                    var hasProcedures = false;
                    $('.procedure-type-combo-box').each(function (idx, itm) {
                        if ($(itm).val() != "") {
                            hasProcedures = true;
                        }
                    });

                    if (hasProcedures) {
                        if (!confirm('Changing the template type will loose any procedures already set. Continue?')) {
                            canContinue = false;
                        }
                    }

                    if (canContinue) {
                        $find('<%=RadAjaxManager1.ClientID%>').ajaxRequest('changeGIType');
                    }
                    else {
                        if ($(ctrl).val() == "1") {
                            $('#<%=GIProcedureRBL.ClientID %>').find("input[value='0']").prop("checked", true);
                            $('#<%=GIProcedureRBL.ClientID %>').find("input[value='1']").prop("checked", false);
                        }
                        else {
                            $('#<%=GIProcedureRBL.ClientID %>').find("input[value='0']").prop("checked", false);
                            $('#<%=GIProcedureRBL.ClientID %>').find("input[value='1']").prop("checked", true);
                        }
                    }
            }

            function toggleSlotsGridColumns(chkBox) {
                var grid = $find("<%=SlotsRadGrid.ClientID %>");

                if (grid) {
                    var masterTable = grid.get_masterTableView()
                    if (masterTable) {
                        if ($(chkBox).val() == 1) {
                            masterTable.showColumn(2);
                            masterTable.showColumn(3);
                        }
                        else {
                            masterTable.hideColumn(2);
                            masterTable.hideColumn(3);
                        }
                    }
                }
            }

            function procedureTypeEvent(ddl) {
                var id = $(ddl).attr("id");
                var slotValue = $find(id).get_text();

                var grid = $find("<%=SlotsRadGrid.ClientID %>");
                var MasterTable = grid.get_masterTableView();
                var selectedRows = MasterTable.get_selectedItems();

                if (selectedRows.length > 1) {
                    $('.procedure-type-combo-box').off('change');

                    for (var i = 0; i < selectedRows.length; i++) {
                        var row = selectedRows[i];
                        var comboBox = $(selectedRows[i].get_element()).find('.procedure-type-combo-box');
                        if (comboBox) {
                            $(comboBox).off('change');
                            $find($(comboBox).attr("id")).set_text(slotValue);
                        }
                    }
                    $('.procedure-type-combo-box').on('change', function () { slotEvent(this) });
                }
            }

            function slotEvent(ddl) {
                var id = $(ddl).attr("id");
                var slotValue = $find(id).get_text();

                var grid = $find("<%=SlotsRadGrid.ClientID %>");
                var MasterTable = grid.get_masterTableView();
                var selectedRows = MasterTable.get_selectedItems();

                var selectedItem = $find(id).findItemByText(slotValue);
                var backColor = $($(selectedItem)[0].get_element()).css("backgroundColor");

                if (selectedRows.length > 1) {
                    $('.slot-combo-box').off('change');

                    for (var i = 0; i < selectedRows.length; i++) {
                        var row = selectedRows[i];
                        var comboBox = $(selectedRows[i].get_element()).find('.slot-combo-box');
                        if (comboBox) {
                            $(comboBox).off('change');
                            $find($(comboBox).attr("id")).set_text(slotValue);
                            var tr = $(comboBox).closest('tr');
                            if (tr) {
                                $(tr).css("background-color", backColor);
                            }
                        }
                    }
                    $('.slot-combo-box').on('change', function () {
                        slotEvent(this)
                    });
                }
                else {
                    var tr = $(ddl).closest('tr');
                    if (tr) {
                        $(tr).css("background", backColor);
                    }
                }
                grid.clearSelectedItems();
            }

            function CheckForValidPage() {
                var valid = Page_ClientValidate("SaveSlots");
                if (!valid) {
                    $("#<%=ServerErrorLabel.ClientID%>").hide();
                    $find("<%=ValidationNotification.ClientID%>").show();
                    return false;
                }
                else {
                    return true;
                }
            }

            function CloseAndRebind(args) {
                GetRadWindow().BrowserWindow.refreshGrid(args);
                GetRadWindow().close();
            }

            function GetRadWindow() {
                var oWindow = null;
                if (window.radWindow) oWindow = window.radWindow; //Will work in Moz in all cases, including clasic dialog
                else if (window.frameElement.radWindow) oWindow = window.frameElement.radWindow; //IE (and Moz as well)

                return oWindow;
            }

            function onSlotDataBound(sender, eventArgs) {

                var item = eventArgs.get_item();
                var dataItem = eventArgs.get_dataItem();
                var phone = dataItem.BackgroundColor;
                item.get_attributes().setAttribute("data-color", ForeColor);
            }



        </script>
    </telerik:RadScriptBlock>
</head>

<body>
    <form id="form1" runat="server">
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Metro" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />

        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest">
            <AjaxSettings>
                <telerik:AjaxSetting AjaxControlID="GenerateSlotButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="SlotsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                        <telerik:AjaxUpdatedControl ControlID="TotalPointsLabel" />
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="SaveButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="SlotsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="RadAjaxManager1">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="SlotsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                        <telerik:AjaxUpdatedControl ControlID="TotalPointsLabel" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="SlotsRadGrid">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="SlotsRadGrid" />
                        <telerik:AjaxUpdatedControl ControlID="TotalPointsLabel" />
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                        <telerik:AjaxUpdatedControl ControlID="rbGIProcedure" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="GIProcedureRBL">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="GIProcedureRBL" />
                        <telerik:AjaxUpdatedControl ControlID="ProcedureTypesComboBox" />
                        <telerik:AjaxUpdatedControl ControlID="SlotsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="OperatingHospitalDropdown">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="OperatingHospitalDropdown" />
                        <telerik:AjaxUpdatedControl ControlID="ProcedureTypesComboBox" />
                        <telerik:AjaxUpdatedControl ControlID="TotalPointsLabel" />
                        <telerik:AjaxUpdatedControl ControlID="SlotsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="TrainingCheckbox">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="TrainingCheckbox" UpdatePanelRenderMode="Inline" />
                        <telerik:AjaxUpdatedControl ControlID="ProcedureTypesComboBox" />
                        <telerik:AjaxUpdatedControl ControlID="TotalPointsLabel" />
                        <telerik:AjaxUpdatedControl ControlID="SlotsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="ProcedureTypesComboBox">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="PointsRadNumericTextBox" />
                        <telerik:AjaxUpdatedControl ControlID="SlotLengthRadNumericTextBox" />
                        <telerik:AjaxUpdatedControl ControlID="SlotQtyRadNumericTextBox" />
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="btnSaveAndApply">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="SlotsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                        <telerik:AjaxUpdatedControl ControlID="PointsRadNumericTextBox" />
                        <telerik:AjaxUpdatedControl ControlID="ProcedureTypesComboBox" />
                        <telerik:AjaxUpdatedControl ControlID="SlotLengthRadNumericTextBox" />
                        <telerik:AjaxUpdatedControl ControlID="SlotQtyRadNumericTextBox" />
                        <telerik:AjaxUpdatedControl ControlID="SlotComboBox" />
                        <telerik:AjaxUpdatedControl ControlID="TotalPointsLabel" />
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
        </telerik:RadAjaxManager>

        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro" />

        <telerik:RadFormDecorator ID="UserMaintenanceRadFormDecorator" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Metro" />
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="680" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Metro">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Height="530px" Scrolling="None">

                <asp:ObjectDataSource ID="SlotStatusObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="GetSlotStatus">
                    <SelectParameters>
                        <asp:Parameter Name="GI" DbType="Byte" DefaultValue="1" />
                        <asp:Parameter Name="nonGI" DbType="Byte" DefaultValue="1" />
                    </SelectParameters>
                </asp:ObjectDataSource>

                <asp:ObjectDataSource ID="GuidelineObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="GetGuidelines">
                    <SelectParameters>
                        <asp:ControlParameter ControlID="GIProcedureRBL" Name="IsGI" Type="Byte" PropertyName="SelectedValue" />
                        <asp:ControlParameter ControlID="OperatingHospitalDropdown" Name="operatingHospital" Type="string" PropertyName="SelectedValue" />
                    </SelectParameters>
                </asp:ObjectDataSource>
                <asp:ObjectDataSource ID="OperatingHospitalObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess" SelectMethod="GetOperatingHospitals" />
                <asp:ObjectDataSource ID="NonGIProceduresObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess" SelectMethod="GetNonGIProcedures" />

                <div id="FormDiv" runat="server" style="width: 700px;">
                    <div style="margin-left: 10px; padding-top: 5px; width: 700px;" class="rptText">
                        <asp:HiddenField runat="server" ID="listRuleId" Value="0"/>
                        <table style="width: 95%;">
                            <tr>
                                <td>
                                    <asp:Label runat="server" Text="Hospital" /></td>
                                <td>
                                    <telerik:RadComboBox ID="OperatingHospitalDropdown" runat="server" DataTextField="HospitalName" DataValueField="OperatingHospitalId" Width="250" OnSelectedIndexChanged="OperatingHospitalDropdown_SelectedIndexChanged" AutoPostBack="true"/>
                                </td>
                                <td>
                                    <asp:Label runat="server" Text="Training" Width="49px" /><asp:CheckBox ID="TrainingCheckbox" runat="server" OnCheckedChanged="TrainingCheckbox_CheckedChanged" AutoPostBack="true" />
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:Label runat="server" Text="List type" Width="80" />
                                </td>
                                <td colspan="2">
                                    <table>
                                        <tr>
                                            <td>
                                                <asp:RadioButtonList ID="GIProcedureRBL" runat="server" RepeatDirection="Horizontal" CssClass="FormatRBL" Width="200" OnSelectedIndexChanged="GIProcedureRBL_SelectedIndexChanged" AutoPostBack="true">
                                                    <asp:ListItem Text="Endoscopic" Value="1" Selected="True" />
                                                </asp:RadioButtonList>
                                            </td>
                                            <td></td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:Label runat="server" Text="Template name" />
                                </td>
                                <td>
                                    <asp:TextBox ID="ListNameTextBox" runat="server" Width="200" />
                                    <asp:RequiredFieldValidator ID="ListNameRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                                        ControlToValidate="ListNameTextBox" EnableClientScript="true" Display="Dynamic"
                                        ErrorMessage="Template name is required" Text="*" ToolTip="This is a required field"
                                        ValidationGroup="SaveSlots">
                                    </asp:RequiredFieldValidator>
                                </td>
                                <td style="padding-left: 40px;"></td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:Label runat="server" Text="Endoscopist" />
                                </td>
                                <td>
                                    <telerik:RadComboBox ID="EndoscopistDropDown" Skin="Metro" runat="server" Width="200" Filter="StartsWith" AutoPostBack="true" />
                                </td>
                                <td style="padding-left: 40px;"></td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:Label runat="server" Text="List consultant" />
                                </td>
                                <td>
                                    <telerik:RadComboBox ID="ListConsultantDropDown" runat="server" AutoPostBack="false" Filter="StartsWith" Width="200" />
                                </td>
                                <td style="padding-left: 40px;"></td>
                            </tr>
                            <tr>
                                <td colspan="3">
                                    <div style="float: left;">
                                        <telerik:RadButton ID="GenerateSlotButton" runat="server" Text="Add slot" Skin="Metro" CausesValidation="true"
                                            OnClientClicked="showAddNewWindow" Icon-PrimaryIconCssClass="telerikGenerate" AutoPostBack="false" />
                                    </div>
                                    <div style="float: right; margin-right: 5px; font-weight: bold; line-height: 20px; font-size: 12px;">
                                        Total points:&nbsp;<asp:Label ID="TotalPointsLabel" runat="server" Text="0" />
                                    </div>
                                </td>
                            </tr>
                        </table>
                        <table>
                            <tr>
                                <td>
                                    <div style="padding-bottom: 5px" class="gi-div">
                                        <div style="float: left; padding-right: 5px; height: 240px;">
                                            <telerik:RadGrid ID="SlotsRadGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="true" Width="650" Height="240" Skin="Metro" AllowPaging="false" Style="margin-bottom: 10px;"
                                                OnItemCommand="SlotsRadGrid_ItemCommand">
                                                <HeaderStyle Font-Bold="true" />
                                                <MasterTableView ShowHeadersWhenNoRecords="true" ClientDataKeyNames="LstSlotId" DataKeyNames="LstSlotId" TableLayout="Fixed">
                                                    <Columns>
                                                        <telerik:GridBoundColumn DataField="LstSlotId" HeaderText="" HeaderStyle-Width="0px" ItemStyle-Width="0px" />
                                                        <telerik:GridTemplateColumn HeaderText="Slots" UniqueName="Slots">
                                                            <ItemTemplate>
                                                                <telerik:RadComboBox ID="SlotComboBox" CssClass="slot-combo-box" Width="90%" runat="server" DataSourceID="SlotStatusObjectDataSource" DataTextField="Description" DataValueField="StatusId" OnItemDataBound="SlotComboBox_ItemDataBound" SelectedValue='<%#Bind("SlotId")%>' />
                                                            </ItemTemplate>
                                                        </telerik:GridTemplateColumn>

                                                        <telerik:GridTemplateColumn HeaderText="Procedure (reserved for)" UniqueName="Guidelines" HeaderStyle-Width="190px">
                                                            <ItemTemplate>
                                                                <telerik:RadComboBox ID="GuidelineComboBox" CssClass="procedure-type-combo-box" OnSelectedIndexChanged="GuidelineComboBox_SelectedIndexChanged" AutoPostBack="true" runat="server" DataSourceID="GuidelineObjectDataSource" DataTextField="SchedulerProcName" DataValueField="ProcedureTypeId" SelectedValue='<%#Eval("ProcedureTypeId")%>' />
                                                            </ItemTemplate>
                                                        </telerik:GridTemplateColumn>
                                                        <telerik:GridTemplateColumn HeaderText="Points">
                                                            <ItemTemplate>
                                                                <telerik:RadNumericTextBox ID="PointsRadNumericTextBox" runat="server" IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="0.5" Width="35px"
                                                                    MinValue="0.5" MaxLength="3" MaxValue="1440" Value='<%#Convert.ToDecimal(Eval("Points")) %>'
                                                                    OnTextChanged="PointsRadNumericTextBox_TextChanged" AutoPostBack="true">
                                                                    <NumberFormat DecimalDigits="1" />
                                                                </telerik:RadNumericTextBox>
                                                            </ItemTemplate>
                                                        </telerik:GridTemplateColumn>
                                                        <telerik:GridTemplateColumn HeaderText="Slot length">
                                                            <ItemTemplate>
                                                                <telerik:RadNumericTextBox ID="SlotLengthRadNumericTextBox" runat="server" IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="1" Width="35px"
                                                                    MinValue="1" MaxLength="3" MaxValue="1440" Value='<%#CInt(Eval("Minutes")) %>'>
                                                                    <NumberFormat DecimalDigits="0" />
                                                                </telerik:RadNumericTextBox>
                                                            </ItemTemplate>
                                                        </telerik:GridTemplateColumn>
                                                        <telerik:GridTemplateColumn HeaderText="Blocked" UniqueName="Suppresse" HeaderStyle-Width="55px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" Visible="false">
                                                            <ItemTemplate>
                                                                <asp:CheckBox ID="SuppressedCheckBox" runat="server" Checked='<%#Bind("Suppressed")%>' />
                                                            </ItemTemplate>
                                                        </telerik:GridTemplateColumn>
                                                        <telerik:GridTemplateColumn HeaderText="Remove" UniqueName="Remove" HeaderStyle-Width="65px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                                                            <ItemTemplate>
                                                                <asp:LinkButton ID="lnlRemoveSlot" runat="server" Text="Remove" CommandName="remove" />
                                                            </ItemTemplate>
                                                        </telerik:GridTemplateColumn>
                                                    </Columns>
                                                </MasterTableView>
                                                <PagerStyle Mode="NextPrev" PagerTextFormat="Navigate Pages {4} Page {0} of {1}; Patients {2} to {3} of {5}" />
                                                <ClientSettings>
                                                    <Selecting AllowRowSelect="True" />
                                                    <Scrolling AllowScroll="True" UseStaticHeaders="true" />
                                                </ClientSettings>
                                            </telerik:RadGrid>
                                        </div>
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
            </telerik:RadPane>
            <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="40px" CssClass="SiteDetailsButtonsPane">
                <div style="margin-left: 10px;">
                    <telerik:RadLabel ID="TemplateNotificationRadLabel" runat="server" ForeColor="Red" Text="This template has bookings against it and therefore cannot be changed" Visible="false" Style="" />
                </div>
                <div id="cmdOtherData" style="height: 10px; margin-left: 10px;">
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Save & Close" Skin="Metro" OnClick="SaveSlots" CausesValidation="true" OnClientClicked="CheckForValidPage" Icon-PrimaryIconCssClass="telerikSaveButton" />
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="Metro" OnClientClicked="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton" />
                </div>
            </telerik:RadPane>
        </telerik:RadSplitter>

        <telerik:RadNotification ID="ValidationNotification" runat="server" Animation="None" Width="400"
            EnableRoundedCorners="true" EnableShadow="true" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
            LoadContentOn="PageLoad" TitleIcon="delete" Position="Center" Style="color: blue;"
            AutoCloseDelay="7000">
            <ContentTemplate>
                <asp:ValidationSummary ID="SaveSlotsValidationSummary" runat="server" ValidationGroup="SaveSlots" DisplayMode="BulletList"
                    EnableClientScript="true" BorderStyle="None" BackColor="Transparent" CssClass="aspxValidationSummary"></asp:ValidationSummary>
                <asp:Label ID="ServerErrorLabel" runat="server" CssClass="aspxValidationSummary" Visible="false"></asp:Label>
            </ContentTemplate>
        </telerik:RadNotification>

        <telerik:RadWindowManager ID="RadWindowManager1" runat="server" ShowContentDuringLoad="False" Style="z-index: 7001" Behaviors="Close, Move" Skin="Metro" EnableShadow="True" Modal="True" Behavior="Close, Move" ReloadOnShow="True">
            <Windows>
                <telerik:RadWindow ID="NewSlotRadWindow" runat="server" ReloadOnShow="true" KeepInScreenBounds="true" AutoSize="true" Title="Add new slot" VisibleStatusbar="false" Modal="True">
                    <ContentTemplate>
                        <div style="padding:15px;">
                            <table>
                                <tr>
                                    <td>Slot type</td>
                                    <td>Procedure</td>
                                    <td>Points</td>
                                    <td>Slot length</td>
                                    <td>Qty</td>
                                </tr>
                                <tr>
                                    <td>
                                        <telerik:RadComboBox ID="SlotComboBox" runat="server" DataSourceID="SlotStatusObjectDataSource" DataTextField="Description" DataValueField="StatusId" ZIndex="9999" />
                                    </td>
                                    <td>
                                        <telerik:RadComboBox ID="ProcedureTypesComboBox" OnSelectedIndexChanged="ProcedureTypesComboBox_SelectedIndexChanged" AutoPostBack="true" runat="server" DataSourceID="GuidelineObjectDataSource" DataTextField="SchedulerProcName" DataValueField="ProcedureTypeId" ZIndex="99999" />
                                    </td>
                                    <td>
                                        <telerik:RadNumericTextBox ID="PointsRadNumericTextBox" runat="server" IncrementSettings-InterceptMouseWheel="false"
                                            IncrementSettings-Step="0.5" Width="35px"
                                            MinValue="0.5" MaxLength="3" MaxValue="1440" Value="1"
                                            AutoPostBack="true">
                                            <NumberFormat DecimalDigits="1" />
                                        </telerik:RadNumericTextBox></td>
                                    <td>
                                        <telerik:RadNumericTextBox ID="SlotLengthRadNumericTextBox" runat="server" IncrementSettings-InterceptMouseWheel="false"
                                            IncrementSettings-Step="1" Width="35px"
                                            MinValue="1" MaxLength="3" MaxValue="1440">
                                            <NumberFormat DecimalDigits="0" />
                                        </telerik:RadNumericTextBox></td>
                                    <td>

                                        <telerik:RadNumericTextBox ID="SlotQtyRadNumericTextBox" runat="server" IncrementSettings-InterceptMouseWheel="false"
                                            IncrementSettings-Step="1" Width="35px"
                                            MinValue="1" MaxLength="3" MaxValue="1440" Value="1">
                                            <NumberFormat DecimalDigits="0" />
                                        </telerik:RadNumericTextBox></td>
                                    <td>
                                        <telerik:RadButton ID="btnSaveAndApply" runat="server" Text="Add" OnClick="btnSaveAndApply_Click" />
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </ContentTemplate>
                </telerik:RadWindow>
            </Windows>
        </telerik:RadWindowManager>
    </form>
</body>

</html>
