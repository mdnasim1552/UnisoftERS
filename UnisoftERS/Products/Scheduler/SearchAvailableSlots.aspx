<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="SearchAvailableSlots.aspx.vb" Inherits="UnisoftERS.SearchAvailableSlots" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="../../Scripts/jquery-1.11.0.min.js"></script>
    <script src="../../Scripts/global.js"></script>

    <link href="../../Styles/Site.css" rel="stylesheet" />

    <telerik:RadScriptBlock runat="server">
        <script type="text/javascript">
            var docURL = document.URL;
        </script>
    </telerik:RadScriptBlock>
</head>
<body>
    <form id="form1" runat="server">
        <telerik:RadScriptManager runat="server" />
        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Metro" />


        <asp:ObjectDataSource ID="EndoscopistObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="GetEndoscopist">
            <SelectParameters>
                <asp:ControlParameter Name="IsGIConsultant" ControlID="SearchGIProcedureRadioButtons" PropertyName="SelectedValue" DbType="Boolean" DefaultValue="true" />
            </SelectParameters>
        </asp:ObjectDataSource>
        <div id="FormDiv">
            <div id="SearchAvailableSlotDiv" runat="server" style="width: 955px; height: 560px; z-index: 999998; position: absolute;">
                <telerik:RadNotification ID="SearchWindowRadNotification" runat="server" VisibleOnPageLoad="false" />

                <div id="divResults" runat="server" visible="false" style="width: 95%;">
                    <fieldset>
                        <legend>Search criteria&nbsp(<asp:Label ID="SearchCriteriaProcedureGITypeLabel" runat="server" />)</legend>
                        <asp:Label ID="SearchCriteriaDetailsLabel" runat="server" />
                        <div style="float: left">
                            <table>
                                <tr>
                                    <td>Endoscopist:</td>
                                    <td>
                                        <asp:Label ID="SCEndoscopistLabel" runat="server" /></td>
                                </tr>
                                <tr>
                                    <td>Procedure(s):</td>
                                    <td>
                                        <asp:Label ID="SCProceduresLabel" runat="server" /></td>
                                </tr>
                                <tr>
                                    <td>Type of slot:</td>
                                    <td>
                                        <asp:Label ID="SCSlotTypeLabel" runat="server" /></td>
                                </tr>
                                <tr>
                                    <td>Gender:</td>
                                    <td>
                                        <asp:Label ID="SCGenderLabel" runat="server" /></td>
                                </tr>
                                <tr>
                                    <td>Days:</td>
                                    <td>
                                        <asp:Label ID="SCDaysLabel" runat="server" /></td>
                                </tr>
                            </table>
                        </div>
                        <div style="float: right;">
                            <table>
                                <tr>
                                    <td>Referral Date:</td>
                                    <td>
                                        <asp:Label ID="SCReferralDateLabel" runat="server" /></td>
                                </tr>
                                <tr>
                                    <td>Breach Date:</td>
                                    <td>
                                        <asp:Label ID="SCBreachDateLabel" runat="server" /></td>
                                </tr>
                                <tr>
                                    <td>Search from Date:</td>
                                    <td>
                                        <asp:Label ID="SCSearchFromDateLabel" runat="server" /></td>
                                </tr>
                            </table>
                        </div>
                    </fieldset>
                    <telerik:RadButton ID="ChangeSearchCriteriaButton" runat="server" Text="Change search criteria" OnClick="ChangeSearchCriteriaButton_Click" />
                    <br />
                    <div id="NoResultsDiv" runat="server" visible="false" style="margin-top: 30px; text-align: center;">
                        <asp:Label ID="NoResultsLabel" runat="server" Text="No results found" />
                        <div runat="server" height="78px" style="padding-top: 5px; text-align: center;">
                            <telerik:RadButton ID="CloseNoResultsDivButton" runat="server" Text="Close" Skin="Metro" OnClientClicked="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton" AutoPostBack="False" />
                        </div>
                    </div>
                    <div style="height: 400px; overflow-y: auto; overflow-x: hidden;">



                        <asp:Repeater ID="AvailableSlotsResultsRepeater" runat="server" OnItemCreated="AvailableSlotsResultsRepeater_ItemCreated">
                            <HeaderTemplate>
                                <table>
                            </HeaderTemplate>
                            <ItemTemplate>
                                <tr>
                                    <td>
                                        <asp:Label ID="SlotDateLabel" runat="server" Text='<%#Eval("SlotDate") %>' CssClass="divWelcomeMessage" /></td>
                                </tr>
                                <tr>
                                    <td>
                                        <telerik:RadGrid ID="SlotsRadGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false" AllowSorting="true"
                                            Skin="Metro" AllowPaging="false" Style="margin-bottom: 10px; width: 95%;" OnItemCommand="SlotsRadGrid_ItemCommand" EnableHeaderContextMenu="true" EnableHeaderContextFilterMenu="true">
                                            <MasterTableView TableLayout="Fixed" CssClass="MasterClass" DataKeyNames="RoomID,DiaryId">
                                                <Columns>
                                                    <telerik:GridBoundColumn DataField="SlotTime" HeaderText="Time" SortExpression="SlotTime" HeaderStyle-Width="160px" HeaderStyle-Height="0" AllowSorting="false" />
                                                    <telerik:GridBoundColumn DataField="Endoscopist" HeaderText="Endoscopist" SortExpression="Endoscopist" HeaderStyle-Width="130px" HeaderStyle-Height="0" AllowSorting="false" ItemStyle-Wrap="true" />
                                                    <telerik:GridBoundColumn DataField="RoomName" HeaderText="Room" SortExpression="RoomName" HeaderStyle-Width="150px" HeaderStyle-Height="0" AllowSorting="false" ShowSortIcon="true" />
                                                    <telerik:GridBoundColumn DataField="Template" HeaderText="Template" SortExpression="Template" HeaderStyle-Width="100px" HeaderStyle-Height="0" AllowSorting="false" />
                                                    <telerik:GridBoundColumn DataField="SlotType" HeaderText="Type" SortExpression="SlotType" HeaderStyle-Width="100px" HeaderStyle-Height="0" AllowSorting="false" ShowSortIcon="true" />
                                                    <telerik:GridBoundColumn DataField="Reserved" HeaderText="Reserved" SortExpression="Reserved" HeaderStyle-Width="100px" HeaderStyle-Height="0" AllowSorting="false" ShowSortIcon="true" />
                                                    <telerik:GridTemplateColumn HeaderStyle-Width="50px">
                                                        <ItemTemplate>
                                                            <asp:LinkButton ID="GoToDateLinkButton" runat="server" Text="View slots" Font-Italic="true" CommandArgument='<%#Eval("AvailableDate") %>' CommandName="SelectSlot" />&nbsp;

                                                        </ItemTemplate>
                                                    </telerik:GridTemplateColumn>
                                                </Columns>
                                            </MasterTableView>
                                            <ClientSettings>
                                                <ClientEvents OnRowContextMenu="RowContextMenu" />
                                                <Selecting AllowRowSelect="true" />
                                            </ClientSettings>
                                        </telerik:RadGrid>
                                        <input type="hidden" id="radGridClickedRowIndex" name="radGridClickedRowIndex" />

                                        <telerik:RadContextMenu ID="RadMenu1" runat="server"
                                            EnableRoundedCorners="true" EnableShadows="true" CssClass="context-menu-popup" OnItemCreated="RadMenu1_ItemCreated">
                                            <Items>
                                                <telerik:RadMenuItem Text="Make Offer">
                                                </telerik:RadMenuItem>
                                                <telerik:RadMenuItem Text="Go to slot">
                                                </telerik:RadMenuItem>
                                            </Items>
                                        </telerik:RadContextMenu>
                                    </td>
                                </tr>
                            </ItemTemplate>
                            <FooterTemplate>
                                </table>
                            </FooterTemplate>
                        </asp:Repeater>
                    </div>

                </div>

                <div id="divFilters" runat="server" visible="false">
                    <table style="width: 100%;">
                        <tr id="MoveBookingTR" runat="server" visible="false">
                            <td colspan="3" style="text-align: center;">
                                <fieldset>
                                    <legend>When this patient is moved...</legend>
                                    <div style="margin-left: 30%;">
                                        <asp:RadioButtonList ID="WhenPatientMovedActionRadioButtonList" runat="server" RepeatDirection="Horizontal">
                                            <asp:ListItem Selected="True">Leave as free slot</asp:ListItem>
                                            <asp:ListItem>Move everyone up in the list</asp:ListItem>
                                        </asp:RadioButtonList>
                                    </div>
                                    <br />
                                    Please enter a reason for the move
                                        <telerik:RadComboBox ID="ReasonForMoveDropdown" runat="server">
                                            <Items>
                                                <telerik:RadComboBoxItem Text="Patient did not attend" />
                                            </Items>
                                        </telerik:RadComboBox>
                                </fieldset>
                            </td>
                        </tr>
                        <tr>
                            <td valign="top" colspan="2">
                                <fieldset class="search-fieldset">
                                    <legend>Search Criteria</legend>
                                    <div>
                                        <asp:Label ID="SearchEndoscopist" runat="server">Endoscopist:</asp:Label>&nbsp;
                                            <telerik:RadComboBox ID="SearchEndoscopistDropdown" runat="server" Style="z-index: 9999;" CheckBoxes="true" EmptyMessage="Any" DataSourceID="EndoscopistObjectDataSource" DataTextField="EndoName" DataValueField="UserID" />

                                        <br />
                                        <asp:RadioButtonList ID="EndoscopistGenderRadioButtonList" runat="server" AutoPostBack="false" RepeatDirection="Horizontal">
                                            <asp:ListItem Text="Any" Selected="true" Value="0" />
                                            <asp:ListItem Value="m" Text="Male" />
                                            <asp:ListItem Value="f" Text="Female" />
                                        </asp:RadioButtonList><br />
                                    </div>
                                    <div>
                                        Refferal date:&nbsp;<telerik:RadDatePicker ID="ReferalDateDatePicker" runat="server" MinDate='<%# DateTime.Now.Date() %>' MaxDate="01/01/3000" />
                                        &nbsp;
                                            Breach date:&nbsp;<telerik:RadDatePicker ID="BreachDateDatePicker" runat="server" MinDate='<%# DateTime.Now.Date().AddDays(7 * 6) %>' MaxDate="01/01/3000" Style="z-index: 999999 !important;" />
                                        <br />
                                        Start searching
                                            <telerik:RadNumericTextBox ID="SearchWeeksBeforeTextBox" runat="server" Value="2" ShowSpinButtons="true"
                                                IncrementSettings-InterceptMouseWheel="true"
                                                IncrementSettings-Step="1"
                                                Width="50px"
                                                MinValue="0" UpdateValueEvent="PropertyChanged" ClientEvents-OnValueChanged="updateSearchDate">
                                                <NumberFormat DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        weeks before breach date on<telerik:RadDatePicker ID="SearchDateDatePicker" runat="server" MaxDate="01/01/3000" />
                                    </div>
                                    <div>
                                        <div style="float: left; padding-top: 5px;">Search for&nbsp;</div>
                                        <div style="float: left;">
                                            <asp:RadioButtonList ID="SearchGIProcedureRadioButtons" runat="server" RepeatDirection="Horizontal" AutoPostBack="true">
                                                <asp:ListItem Text="GI Procedures" Value="true" Selected="True" />
                                                <asp:ListItem Text="Non-GI Procedures" Value="false" />
                                            </asp:RadioButtonList>
                                        </div>
                                    </div>
                                </fieldset>
                            </td>
                            <td valign="top" rowspan="2">
                                <fieldset>
                                    <legend>Include these procedures in search</legend>
                                    <asp:CheckBox ID="ShowOnlyReservedSlotsCheckBox" runat="server" Text="Show only reserved slots (guidelines)" />
                                    <br />
                                    <div style="padding-top: 5px;">
                                        Length of slot
                                            <telerik:RadNumericTextBox ID="LengthOfSlotsNumericTextbox" CssClass="slot-length" runat="server" Value="0"
                                                ShowSpinButtons="true"
                                                IncrementSettings-InterceptMouseWheel="true"
                                                IncrementSettings-Step="5"
                                                Width="50px"
                                                MinValue="0">
                                                <NumberFormat DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                    </div>
                                    <div id="non-gi-procedure-types" style="padding-bottom: 3px; display: none;">
                                        <div>
                                            <telerik:RadComboBox ID="nonGIProceduresDropdown" runat="server" Style="z-index: 9999;" DataSourceID="NonGIProceduresObjectDataSource" DataTextField="ProcedureType" EmptyMessage="All non-GI procedures" DataValueField="ProcedureTypeId" CheckBoxes="true" />
                                        </div>
                                        <div style="float: left">
                                            <table cellpadding="4">
                                                <tr>
                                                    <td>
                                                        <asp:RadioButton ID="DiagnosticsRadioButton" runat="server" Text="Diagnostic" TextAlign="Right" GroupName="non-gi-procedure-group" /></td>
                                                    <td>
                                                        <asp:RadioButton ID="TherapeuticRadioButton" runat="server" Text="Therapeutic" TextAlign="Right" GroupName="non-gi-procedure-group" /></td>
                                                    <td></td>
                                                </tr>
                                            </table>
                                        </div>
                                    </div>
                                    <div id="gi-procedure-types">
                                        <div style="float: left;">
                                            <asp:Repeater ID="rptProcedureTypes" runat="server" DataSourceID="ProcedureTypesObjectDataSource" OnItemDataBound="rptProcedureTypes_ItemDataBound">
                                                <HeaderTemplate>
                                                    <table cellpadding="4">
                                                        <tr>
                                                            <td>Diagnostic</td>
                                                            <td>Therapeutic</td>
                                                            <td></td>
                                                        </tr>
                                                </HeaderTemplate>
                                                <ItemTemplate>
                                                    <tr>
                                                        <td>
                                                            <asp:HiddenField ID="ProcedureTypeHiddenField" runat="server" Value='<%#Eval("SchedulerProcName") %>' />
                                                            <asp:HiddenField ID="ProcedureTypeIDHiddenField" runat="server" Value='<%#Eval("ProcedureTypeID") %>' />
                                                            <asp:CheckBox ID="DiagnosticProcedureTypesCheckBox" runat="server" Text='<%#Eval("SchedulerProcName") %>' data-check-type="diagnostic" GroupName="procedure-group" />
                                                        </td>
                                                        <td>
                                                            <asp:CheckBox ID="TherapeuticProcedureTypesCheckBox" runat="server" data-val-id='<%#Eval("ProcedureTypeID") %>' Text='<%#Eval("SchedulerProcName") %>' data-check-type="therapeutic" GroupName="procedure-group" />
                                                        </td>
                                                        <td>
                                                            <asp:Button ID="DefineTherapeuticProcedureButton" runat="server" data-val-id='<%#Eval("ProcedureTypeID") %>' Text="Define" Enabled="false" CssClass="define-button" data-proc-type='<%#Eval("SchedulerProcName") %>' data-proc-id='<%#Eval("ProcedureTypeID") %>' />
                                                        </td>
                                                    </tr>
                                                </ItemTemplate>
                                                <FooterTemplate>
                                                    </table>
                                                </FooterTemplate>
                                            </asp:Repeater>
                                        </div>
                                    </div>
                                </fieldset>
                            </td>
                        </tr>
                        <tr>
                            <td valign="top">
                                <fieldset class="slot-filter">
                                    <legend>Include these slots in search</legend>
                                    <asp:CheckBox ID="AllSlotsCheckBox" runat="server" Text="ALL slots" Checked="true" />
                                    <asp:CheckBoxList ID="IncludedSlotsCheckBoxList" runat="server" DataSourceID="SlotStatusObjectDataSource" DataValueField="StatusId" DataTextField="Description" />
                                </fieldset>
                            </td>
                            <td valign="top">
                                <fieldset>
                                    <legend>Include these days in search</legend>
                                    <table class="search-days" cellpadding="4">
                                        <tr>
                                            <td></td>
                                            <td>Morning</td>
                                            <td>Afternoon</td>
                                            <td>Evening</td>
                                        </tr>
                                        <tr data-day="monday">
                                            <td>
                                                <asp:CheckBox ID="MondayCheckBox" runat="server" Text="Monday" TextAlign="Right" /></td>
                                            <td>
                                                <asp:CheckBox ID="MondayMorningCheckBox" runat="server" /></td>
                                            <td>
                                                <asp:CheckBox ID="MondayAfternoonCheckBox" runat="server" /></td>
                                            <td>
                                                <asp:CheckBox ID="MondayEveningCheckBox" runat="server" /></td>
                                        </tr>
                                        <tr data-day="tuesday">
                                            <td>
                                                <asp:CheckBox ID="TuesdayCheckBox" runat="server" Text="Tuesday" TextAlign="Right" /></td>
                                            <td>
                                                <asp:CheckBox ID="TuesdayMorningCheckBox" runat="server" /></td>
                                            <td>
                                                <asp:CheckBox ID="TuesdayAfternoonCheckBox" runat="server" /></td>
                                            <td>
                                                <asp:CheckBox ID="TuesdayEveningCheckBox" runat="server" /></td>
                                        </tr>
                                        <tr data-day="wednesday">
                                            <td>
                                                <asp:CheckBox ID="WednesdayCheckBox" runat="server" Text="Wednesday" TextAlign="Right" /></td>
                                            <td>
                                                <asp:CheckBox ID="WednesdayMorningCheckBox" runat="server" /></td>
                                            <td>
                                                <asp:CheckBox ID="WednesdayAfternoonCheckBox" runat="server" /></td>
                                            <td>
                                                <asp:CheckBox ID="WednesdayEveningCheckBox" runat="server" /></td>
                                        </tr>
                                        <tr data-day="thursday">
                                            <td>
                                                <asp:CheckBox ID="ThursdayCheckBox" runat="server" Text="Thursday" TextAlign="Right" /></td>
                                            <td>
                                                <asp:CheckBox ID="ThursdayMorningCheckBox" runat="server" /></td>
                                            <td>
                                                <asp:CheckBox ID="ThursdayAfternoonCheckBox" runat="server" /></td>
                                            <td>
                                                <asp:CheckBox ID="ThursdayEveningCheckBox" runat="server" /></td>
                                        </tr>
                                        <tr data-day="friday">
                                            <td>
                                                <asp:CheckBox ID="FridayCheckBox" runat="server" Text="Friday" TextAlign="Right" /></td>
                                            <td>
                                                <asp:CheckBox ID="FridayMorningCheckBox" runat="server" /></td>
                                            <td>
                                                <asp:CheckBox ID="FridayAfternoonCheckBox" runat="server" /></td>
                                            <td>
                                                <asp:CheckBox ID="FridayEveningCheckBox" runat="server" /></td>
                                        </tr>
                                        <tr data-day="saturday">
                                            <td>
                                                <asp:CheckBox ID="SaturdayCheckBox" runat="server" Text="Saturday" TextAlign="Right" /></td>
                                            <td>
                                                <asp:CheckBox ID="SaturdayMorningCheckBox" runat="server" /></td>
                                            <td>
                                                <asp:CheckBox ID="SaturdayAfternoonCheckBox" runat="server" /></td>
                                            <td>
                                                <asp:CheckBox ID="SaturdayEveningCheckBox" runat="server" /></td>
                                        </tr>
                                        <tr data-day="sunday">
                                            <td>
                                                <asp:CheckBox ID="SundayCheckBox" runat="server" Text="Sunday" TextAlign="Right" /></td>
                                            <td>
                                                <asp:CheckBox ID="SundayMorningCheckBox" runat="server" /></td>
                                            <td>
                                                <asp:CheckBox ID="SundayAfternoonCheckBox" runat="server" /></td>
                                            <td>
                                                <asp:CheckBox ID="SundayEveningCheckBox" runat="server" /></td>
                                        </tr>
                                    </table>
                                </fieldset>
                            </td>
                        </tr>
                    </table>
                    <div id="buttons" runat="server" height="78px" style="padding-top: 55px; text-align: center;">
                        <telerik:RadButton ID="SearchButton" runat="server" Text="Search" Skin="Metro" Icon-PrimaryIconCssClass="rbSearch" OnClick="SearchButton_Click" />
                        <telerik:RadButton ID="CancelSearchButton" runat="server" Text="Close" Skin="Metro" OnClientClicked="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton" AutoPostBack="False" />
                    </div>
                </div>

                <div id="divWaitlist" runat="server" visible="false">
                    <telerik:RadGrid ID="WaitListGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false"
                        AllowAutomaticDeletes="True" AutoSizeColumnsMode="Fill" AllowSorting="true" Height="537"
                        Skin="Metro" GridLines="None" PageSize="15" AllowPaging="true" CssClass="WrkGridClass">
                        <HeaderStyle Font-Bold="true" BackColor="#25A0DA" />
                        <CommandItemStyle BackColor="WhiteSmoke" />
                        <MasterTableView ShowHeadersWhenNoRecords="true" ClientDataKeyNames="WaitingListId,PatientId" CommandItemDisplay="None" DataKeyNames="WaitingListId,PatientId" TableLayout="Fixed" CssClass="MasterClass"
                            GridLines="None" ItemStyle-Height="28" AlternatingItemStyle-Height="28" AllowFilteringByColumn="true">
                            <Columns>
                                <telerik:GridBoundColumn DataField="Surname" HeaderText="Surname" SortExpression="Surname" HeaderStyle-Width="130px" FilterControlWidth="120px" CurrentFilterFunction="Contains" ShowFilterIcon="false" AutoPostBackOnFilter="true"></telerik:GridBoundColumn>
                                <telerik:GridBoundColumn DataField="Forename1" HeaderText="Forename" SortExpression="Forename1" HeaderStyle-Width="130px" FilterControlWidth="120px" CurrentFilterFunction="Contains" ShowFilterIcon="false" AutoPostBackOnFilter="true"></telerik:GridBoundColumn>
                                <telerik:GridBoundColumn DataField="Gender" HeaderText="Gender" SortExpression="Gender" ItemStyle-HorizontalAlign="Center" FilterControlWidth="15px" CurrentFilterFunction="EqualTo" ShowFilterIcon="false" AutoPostBackOnFilter="true" HeaderStyle-HorizontalAlign="Center" HeaderStyle-Width="75px">
                                    <FilterTemplate>
                                        <telerik:RadComboBox RenderMode="Lightweight" ID="GenderCombo" Width="70" SelectedValue='<%# CType(Container, GridItem).OwnerTableView.GetColumn("Gender").CurrentFilterValue %>'
                                            runat="server" Skin="Metro" OnClientSelectedIndexChanged="GenderComboIndexChanged">
                                            <Items>
                                                <telerik:RadComboBoxItem Text="All" Value="" />
                                                <telerik:RadComboBoxItem Text="Male" Value="Male" />
                                                <telerik:RadComboBoxItem Text="Female" Value="Female" />
                                            </Items>
                                        </telerik:RadComboBox>
                                        <telerik:RadScriptBlock ID="RadScriptBlockGender" runat="server">
                                            <script type="text/javascript">
                                                function GenderComboIndexChanged(sender, args) {
                                                    var tableView = $find("<%# CType(Container, GridItem).OwnerTableView.ClientID %>");
                                                    tableView.filter("Gender", args.get_item().get_value(), "EqualTo");
                                                }
                                            </script>
                                        </telerik:RadScriptBlock>
                                    </FilterTemplate>
                                </telerik:GridBoundColumn>
                                <telerik:GridTemplateColumn HeaderText="DOB" SortExpression="DateOfBirth" HeaderStyle-Width="80px" AllowFiltering="false" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblPatientDOB" runat="server" Text='<%# Eval("DateOfBirth", "{0:dd/MM/yyyy}") %>' />
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridBoundColumn DataField="HospitalNumber" HeaderText="Hosp No" SortExpression="HospitalNumber" HeaderStyle-Width="110px" FilterControlWidth="100px" CurrentFilterFunction="Contains" ShowFilterIcon="false" AutoPostBackOnFilter="true" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center"></telerik:GridBoundColumn>
                                <telerik:GridTemplateColumn HeaderText="Postcode" SortExpression="Postcode" HeaderStyle-Width="80px" FilterControlWidth="70px" CurrentFilterFunction="Contains" ShowFilterIcon="false" AutoPostBackOnFilter="true" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <telerik:RadToolTip RenderMode="Lightweight" ID="RadToolTip1" runat="server" TargetControlID="PostcodeLabel" RelativeTo="Element"
                                            Position="MiddleRight" RenderInPageRoot="true">
                                            <%# DataBinder.Eval(Container, "DataItem.Address")%>
                                        </telerik:RadToolTip>
                                        <asp:Label ID="PostcodeLabel" runat="server" Text='<%#Eval("Postcode") %>' />
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridBoundColumn DataField="ProcedureType" HeaderText="Procedure" SortExpression="ProcedureType" HeaderStyle-Width="120px" FilterControlWidth="120" CurrentFilterFunction="Contains" ShowFilterIcon="false" AutoPostBackOnFilter="false">
                                    <FilterTemplate>
                                        <telerik:RadComboBox AutoPostBack="false" RenderMode="Lightweight" ID="ProcedureCombo" Width="120" SelectedValue='<%# CType(Container, GridItem).OwnerTableView.GetColumn("ProcedureType").CurrentFilterValue %>'
                                            runat="server" Skin="Metro" OnClientSelectedIndexChanged="ProcedureTypeComboIndexChanged" DataSourceID="ProcedureTypesObjectDataSource" DataTextField="ProcedureType" />
                                        <telerik:RadScriptBlock ID="RadScriptBlockProcedureType" runat="server">
                                            <script type="text/javascript">
                                                function ProcedureTypeComboIndexChanged(sender, args) {
                                                    var tableView = $find("<%# CType(Container, GridItem).OwnerTableView.ClientID %>");
                                                    tableView.filter("ProcedureType", args.get_item().get_value(), "EqualTo");
                                                }
                                            </script>
                                        </telerik:RadScriptBlock>
                                    </FilterTemplate>
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn DataField="PriorityDescription" HeaderText="Priority" SortExpression="PriorityDescription" HeaderStyle-Width="110px" CurrentFilterFunction="Contains" ShowFilterIcon="false" AutoPostBackOnFilter="true">
                                    <FilterTemplate>
                                        <telerik:RadComboBox RenderMode="Lightweight" ID="PriorityCombo" Width="110" SelectedValue='<%# CType(Container, GridItem).OwnerTableView.GetColumn("PriorityDescription").CurrentFilterValue %>'
                                            runat="server" Skin="Metro" OnClientSelectedIndexChanged="PriorityComboIndexChanged" DataSourceID="SlotStatusObjectDataSource" DataTextField="Description" />
                                        <telerik:RadScriptBlock ID="RadScriptBlockPriority" runat="server">
                                            <script type="text/javascript">
                                                function PriorityComboIndexChanged(sender, args) {
                                                    var tableView = $find("<%# CType(Container, GridItem).OwnerTableView.ClientID %>");
                                                    tableView.filter("PriorityDescription", args.get_item().get_value(), "EqualTo");
                                                }
                                            </script>
                                        </telerik:RadScriptBlock>
                                    </FilterTemplate>
                                </telerik:GridBoundColumn>
                                <telerik:GridTemplateColumn HeaderText="Date added" SortExpression="DateRaised" HeaderStyle-Width="80px" AllowFiltering="false" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblDateRaised" runat="server" Text='<%# Eval("DateRaised", "{0:dd/MM/yyyy}") %>' />
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridTemplateColumn HeaderText="Due date" SortExpression="DueDate" HeaderStyle-Width="80px" AllowFiltering="false" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblDueDate" runat="server" Text='<%# Eval("DueDate", "{0:dd/MM/yyyy}") %>' />
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridBoundColumn DataField="Referrer" HeaderText="Referrered by" SortExpression="Referrer" HeaderStyle-Width="130px" FilterControlWidth="130" CurrentFilterFunction="Contains" ShowFilterIcon="false" AutoPostBackOnFilter="true">
                                </telerik:GridBoundColumn>
                            </Columns>
                            <NoRecordsTemplate>
                                <div style="margin-top: 10px; margin-bottom: 10px; margin-left: 5px;">
                                    No patients found.
                                </div>
                            </NoRecordsTemplate>
                        </MasterTableView>
                        <PagerStyle Mode="NextPrevAndNumeric" PagerTextFormat="Navigate Pages {4} Page {0} of {1}; Patients {2} to {3} of {5}" AlwaysVisible="true" BackColor="#f9f9f9" />
                        <GroupingSettings CaseSensitive="false" CollapseAllTooltip="Collapse all groups"></GroupingSettings>
                        <ClientSettings EnableRowHoverStyle="true">
                            <Resizing AllowColumnResize="true" ResizeGridOnColumnResize="true" AllowResizeToFit="true" />
                            <Selecting AllowRowSelect="true" />
                            <Scrolling AllowScroll="true" UseStaticHeaders="true" />
                            <ClientEvents OnRowContextMenu="showContextMenuWrk" OnRowSelecting="waitlistRowSelected" OnRowClick="waitlistRowSelected" OnRowDblClick="searchSlotFromWaitlist" />
                        </ClientSettings>
                        <AlternatingItemStyle BackColor="#fafafa" />
                        <HeaderStyle BackColor="#f4f7f9" Font-Bold="true" Height="10" />
                        <SortingSettings SortedBackColor="ControlLight" />
                    </telerik:RadGrid>
                    <asp:HiddenField ID="WaitlistSelectedIdHiddenField" runat="server" />
                    <asp:HiddenField ID="WaitlistPatientHiddenField" runat="server" />

                    <telerik:RadContextMenu ID="WaitlistRadMenu" runat="server" EnableRoundedCorners="true" EnableShadows="true">
                        <Items>
                            <telerik:RadMenuItem Text="Find available slot" ImageUrl="../Images/icons/select.png" NavigateUrl="javascript:searchSlotFromWaitlist();">
                            </telerik:RadMenuItem>
                        </Items>
                    </telerik:RadContextMenu>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
