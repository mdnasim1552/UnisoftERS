<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="ListTemplate.ascx.vb" Inherits="UnisoftERS.ListTemplate" %>

<script type="text/javascript">
    function showAddNewWindow(sender, args) {
        var oWnd = $find("<%= NewSlotRadWindow.ClientID%>");
        if (oWnd != null) {

            $find('<%=SlotComboBox.ClientID%>').get_items().getItem(0).select();
            $find('<%=ProcedureTypesComboBox.ClientID%>').get_items().getItem(0).select();
            $find('<%=PointsRadNumericTextBox.ClientID%>').set_value(1);

            //Mahfuz changed on 10 Oct 2021
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
</script>

<%--<div style="float: left;">
    <telerik:RadButton ID="GenerateSlotButton" runat="server" Text="Add slot" Skin="Metro" CausesValidation="true"
        OnClientClicked="showAddNewWindow" Icon-PrimaryIconCssClass="telerikGenerate" AutoPostBack="false" />
</div>

<div style="float: right; margin-right: 5px; font-weight: bold; line-height: 20px; font-size: 12px;">
    Total points:&nbsp;<asp:Label ID="TotalPointsLabel" runat="server" Text="0" />
</div>--%>

<div style="padding-bottom: 5px" class="gi-div">
    <div style="float: right; margin-right: 5px; font-weight: bold; line-height: 20px; font-size: 12px;">
        Total points:&nbsp;<asp:Label ID="TotalPointsLabel" runat="server" Text="0" />
    </div>
    <div style="float: left; padding-right: 5px; height: 240px;">
        <telerik:RadGrid ID="SlotsRadGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="true" Width="650" Height="240" Skin="Metro" AllowPaging="false" Style="margin-bottom: 10px;"
            OnItemCommand="SlotsRadGrid_ItemCommand" OnItemDataBound="SlotsRadGrid_ItemDataBound">
            <HeaderStyle Font-Bold="true" />
            <MasterTableView ShowHeadersWhenNoRecords="true" ClientDataKeyNames="LstSlotId" DataKeyNames="LstSlotId" TableLayout="Fixed">
                <Columns>
                    <telerik:GridBoundColumn DataField="LstSlotId" HeaderText="" HeaderStyle-Width="0px" ItemStyle-Width="0px" />
                    <telerik:GridTemplateColumn HeaderText="Slots" UniqueName="Slots">
                        <ItemTemplate>
                            <telerik:RadComboBox ID="SlotComboBox" CssClass="slot-combo-box" Width="90%" runat="server" DataSourceID="SlotStatusObjectDataSource" DataTextField="Description" DataValueField="StatusId" OnItemDataBound="SlotComboBox_ItemDataBound" />
                        </ItemTemplate>
                    </telerik:GridTemplateColumn>

                    <telerik:GridTemplateColumn HeaderText="Procedure (reserved for)" UniqueName="Guidelines" HeaderStyle-Width="190px">
                        <ItemTemplate>
                            <telerik:RadComboBox ID="GuidelineComboBox" CssClass="procedure-type-combo-box" OnSelectedIndexChanged="GuidelineComboBox_SelectedIndexChanged" AutoPostBack="true" runat="server" DataTextField="SchedulerProcName" DataValueField="ProcedureTypeId" />

                        </ItemTemplate>
                    </telerik:GridTemplateColumn>
                    <telerik:GridTemplateColumn HeaderText="Points">
                        <ItemTemplate>
                            <telerik:RadNumericTextBox ID="PointsRadNumericTextBox" runat="server" IncrementSettings-InterceptMouseWheel="false"
                                IncrementSettings-Step="0.5" Width="35px"
                                MinValue="0.5" MaxLength="3" MaxValue="1440" Value='<%#Convert.ToDecimal(Eval("Points")) %>' AutoPostBack="true">
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

<asp:ObjectDataSource ID="SlotStatusObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="GetSlotStatus">
    <SelectParameters>
        <asp:Parameter Name="GI" DbType="Byte" DefaultValue="1" />
        <asp:Parameter Name="nonGI" DbType="Byte" DefaultValue="1" />
    </SelectParameters>
</asp:ObjectDataSource>


<asp:ObjectDataSource ID="GuidelineObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="GetGuidelines">
    <SelectParameters>
        <asp:Parameter Name="IsGI" DbType="Byte" />
        <asp:Parameter Name="operatingHospital" />
    </SelectParameters>
</asp:ObjectDataSource>

<telerik:RadWindowManager ID="RadWindowManager1" runat="server" ShowContentDuringLoad="False" Style="z-index: 7001" Behaviors="Close, Move" Skin="Metro" EnableShadow="True" Modal="True" Behavior="Close, Move" ReloadOnShow="True">
    <Windows>
        <telerik:RadWindow ID="NewSlotRadWindow" runat="server" ReloadOnShow="true" KeepInScreenBounds="true" AutoSize="true" Title="Add new slot" VisibleStatusbar="false" Modal="True">
            <ContentTemplate>
                <div style="padding: 15px;">
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
