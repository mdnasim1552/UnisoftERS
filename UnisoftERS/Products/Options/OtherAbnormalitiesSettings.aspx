<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="OtherAbnormalitiesSettings.aspx.vb" Inherits="UnisoftERS.OtherAbnormalitiesSettings" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Other Abnormalities</title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../Scripts/Global.js"></script>
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <link type="text/css" href="../../Styles/Site.css" rel="stylesheet" />
        <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <script type="text/javascript">

            function addOtherAbno(rowIndex) {
                if (rowIndex > -1) {
                    var gvID = $find('<%=OtherAbnoRadGrid.ClientID %>');
                    var masterTableView = gvID.get_masterTableView();
                    var otherAbnoDataItems = masterTableView.get_dataItems()[rowIndex];
                    //get the datakeyname
                    var otherId = otherAbnoDataItems.getDataKeyValue("OtherId");

                    var url = "<%= ResolveUrl("~/Products/Options/EditOtherAbnormality.aspx?otherAbnoId={0}")%>";
                    url = url.replace("{0}", otherId);
                }
                else {
                    var url = "<%= ResolveUrl("~/Products/Options/EditOtherAbnormality.aspx")%>";
                }
                var oWnd = $find("<%= NewEditOtherWindow.ClientID %>");
                oWnd._navigateUrl = url
                oWnd.SetSize(500, 500);

                //Add the name of the function to be executed when RadWindow is closed.

                oWnd.show();
                
                
            }

            function refreshGrid() {
                //var oWnd = $find("<%= NewEditOtherWindow.ClientID %>");
                //oWnd.hide();
                $find("<%= RadAjaxManager1.ClientID %>").ajaxRequest("Rebind");
                
            }
        </script>
        </telerik:RadScriptBlock>

</head>
<body>
    <form id="form1" runat="server">

        <div class="optionsHeading">
            <asp:Label ID="HeadingLabel" runat="server" Text="Other Abnormalities"></asp:Label>
        </div>

        <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />


        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server">
            <AjaxSettings>
                <telerik:AjaxSetting AjaxControlID="RadAjaxManager1">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="OtherAbnoRadGrid" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="OtherAbnoRadGrid">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="OtherAbnoRadGrid" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
        </telerik:RadAjaxManager>

        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro">
        </telerik:RadAjaxLoadingPanel>
        <div id="FormDiv" runat="server" style="margin-top: 10px;">
            <div style="margin-left: 10px; margin-top: 20px;" class="rptText">
                <asp:Panel ID="pnlCancellationReasons" runat="server">
                    <telerik:RadGrid ID="OtherAbnoRadGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false" AllowSorting="true"
                        DataSourceID="OtherAbnoDataSource"
                        Skin="Metro" PageSize="50" AllowPaging="true" Style="margin-bottom: 10px; width: 75%; height: 500px;">
                        <HeaderStyle Font-Bold="true" />
                        <MasterTableView ShowHeadersWhenNoRecords="true" ClientDataKeyNames="OtherId,Abnormality,Summary,Diagnoses,ProcedureType,Active" DataKeyNames="OtherId,Abnormality,Summary,Diagnoses,ProcedureType,Active" TableLayout="Fixed"
                            EnableNoRecordsTemplate="true" CssClass="MasterClass">
                            <Columns>
                                <telerik:GridTemplateColumn UniqueName="EditLinkButtonColumn" HeaderStyle-Width="80px">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="EditLinkButton" runat="server" Text="Edit" ToolTip="Edit Abnormality" Font-Italic="true"></asp:LinkButton>
                                    </ItemTemplate>
                                    <HeaderTemplate>
                                        <telerik:RadButton ID="AddNewOtherAbnoButton" runat="server" Text="Add New" Skin="Metro" AutoPostBack="false" OnClientClicked="addOtherAbno"></telerik:RadButton>
                                    </HeaderTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridBoundColumn DataField="OtherId" Visible="false" />
                                <telerik:GridBoundColumn DataField="Abnormality" HeaderText="Abnormality" HeaderStyle-Width="170px" />
                                <telerik:GridBoundColumn DataField="Summary" HeaderText="Summary" HeaderStyle-Width="170px" />
                                <telerik:GridBoundColumn DataField="Diagnoses" HeaderText="Diagnoses" HeaderStyle-Width="170px" />
                                <telerik:GridBoundColumn DataField="ProcedureType" HeaderText="Procedure" HeaderStyle-Width="80px" />
                                <telerik:GridTemplateColumn ItemStyle-HorizontalAlign="Center" HeaderText="Active" HeaderStyle-Width="50px" HeaderStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:CheckBox ID="ActiveCheckBox" runat="server" Checked='<%# Bind("Active")%>' Enabled="false" />
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                            </Columns>
                            <NoRecordsTemplate>
                                <div style="margin-top: 10px; margin-bottom: 10px; margin-left: 5px;" id="NoRecordsDiv" runat="server">
                                    No Abnormalities found
                                </div>
                            </NoRecordsTemplate>
                        </MasterTableView>
                        <PagerStyle Mode="NumericPages"></PagerStyle>

                        <ClientSettings>
                            <Scrolling AllowScroll="true" UseStaticHeaders="true" />
                            <Selecting AllowRowSelect="true" />
                        </ClientSettings>
                    </telerik:RadGrid>
                </asp:Panel>
            </div>
        </div>
        <asp:ObjectDataSource ID="OtherAbnoDataSource" runat="server" TypeName="UnisoftERS.DataAccess" SelectMethod="GetAllOtherAbno">
            <UpdateParameters>
                <asp:Parameter Name="OtherId" DbType="Int32" DefaultValue="" />
                <asp:Parameter Name="Abnormality" DbType="String" DefaultValue="" />
                <asp:Parameter Name="Summary" DbType="String" DefaultValue="False" />
                <asp:Parameter Name="Diagnoses" DbType="String" DefaultValue="" />
                <asp:Parameter Name="ProcedureType" DbType="String" DefaultValue="" />
                <asp:Parameter Name="Active" DbType="Boolean" DefaultValue="True" />
            </UpdateParameters>
            <InsertParameters>
                <asp:Parameter Name="OtherId" DbType="Int32" DefaultValue="" />
                <asp:Parameter Name="Abnormality" DbType="String" DefaultValue="" />
                <asp:Parameter Name="Summary" DbType="String" DefaultValue="" />
                <asp:Parameter Name="Diagnoses" DbType="String" DefaultValue="" />
                <asp:Parameter Name="ProcedureType" DbType="String" DefaultValue="" />
                <asp:Parameter Name="Active" DbType="Int32" DefaultValue="True" />
            </InsertParameters>
        </asp:ObjectDataSource>

        <telerik:RadWindowManager ID="OtherAbnoRadWindowManager" runat="server"
            Style="z-index: 7001" Behaviors="Close, Move" AutoSize="false" Skin="Metro" EnableShadow="true" Modal="true">
            <Windows>
                <telerik:RadWindow ID="NewEditOtherWindow" runat="server" Modal="true" ReloadOnShow="true" KeepInScreenBounds="true"
                    Width="500px" Height="500px" Title="Add/Edit Other Abnormality" VisibleStatusbar="false" />
            </Windows>
        </telerik:RadWindowManager>

    </form>
</body>
</html>
