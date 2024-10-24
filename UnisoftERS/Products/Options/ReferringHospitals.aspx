<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="ReferringHospitals.aspx.vb" Inherits="UnisoftERS.ReferringHospitals" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Add/Edit referring consultants details</title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../Scripts/Global.js"></script>
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <link type="text/css" href="../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
    </style>

    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <script type="text/javascript">
            $(window).on('load', function () {
            });
            $(document).ready(function () {
            });

            function editHospital(HospitalID, HospitalName) {
                if (HospitalID > 0) {
                $find('<%=NewHospitalTextBox.ClientID%>').set_value(HospitalName);
                    $('#<%=HospitalIdHiddenField.ClientID%>').val(HospitalID);

                    var wnd = $find("<%= HospitalRadWindow.ClientID%>");
                    wnd.show();
                }
            }

            function addHospital() {
                $find('<%=NewHospitalTextBox.ClientID%>').set_value("");
                var wnd = $find("<%= HospitalRadWindow.ClientID%>");
                wnd.show();
            }

            function closeHospital() {
                var wnd = $find("<%= HospitalRadWindow.ClientID%>");
                wnd.close();
            }

            function Show() {
                if (confirm("Are you sure you want to suppress this hospital?")) {
                    return true;
                }
                else {
                    return false;
                }
            }

            function refreshGrid(arg) {
                if (!arg) {
                    window.location.reload();
                }
                else {
                    $find("<%= RadAjaxManager1.ClientID %>").ajaxRequest("RebindAndNavigate");
                }
            }
        </script>
    </telerik:RadScriptBlock>
</head>
<body>
    <form id="form1" runat="server">
        <asp:HiddenField ID="hiddenShowSuppressedItems" runat="server" Value="0" />
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />

        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest">
            <AjaxSettings>
                <telerik:AjaxSetting AjaxControlID="RadWindowManager1">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="ReferringHospitalsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="ReferringHospitalsRadGrid">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="ReferringHospitalsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="HideSuppressButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="FormDiv" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="SuppressedComboBox">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="ReferringHospitalsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="SearchButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="ReferringHospitalsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
        </telerik:RadAjaxManager>

        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro">
        </telerik:RadAjaxLoadingPanel>

        <div class="optionsHeading">
            <asp:Label ID="HeadingLabel" runat="server" Text="Add/Edit referring hospitals"></asp:Label>
        </div>

        <telerik:RadFormDecorator runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />

        <div id="FormDiv" runat="server" style="margin-top: 10px;">
            <div id="searchBox" runat="server" class="optionsBodyText" style="margin-left: 10px; width: 556px">
                <asp:Panel ID="Panel1" runat="server" DefaultButton="SearchButton">
                    <table style="width: 100%;">
                        <tr>
                            <td style="padding-top: 10px; padding-left: 10px; width: 30%;">Search Hospital Name:
                            </td>
                            <td style="padding: 10px 10px 0px 10px;">
                                <telerik:RadTextBox ID="SearchTextBox" runat="server" Width="100%" EmptyMessage="Enter search text" Skin="Vista" CssClass="filterTxt" />
                            </td>
                            <td style="padding: 10px 10px 0px 10px;">
                                <telerik:RadButton ID="SearchButton" runat="server" Text="Search" Font-Bold="true" Skin="Vista" CssClass="filterBtn" />
                            </td>
                        </tr>
                    </table>
                </asp:Panel>
                <div style="padding-top: 10px; padding-left: 12px;">
                    Show:
                    <telerik:RadComboBox ID="SuppressedComboBox" runat="server" Skin="Windows7" AutoPostBack="true" OnSelectedIndexChanged="HideSuppressButton_Click" CssClass="filterBtn">
                        <Items>
                            <telerik:RadComboBoxItem Text="All hospitals" Value="" Selected="true" />
                            <telerik:RadComboBoxItem Text="Suppressed hospitals" Value="1" />
                            <telerik:RadComboBoxItem Text="Unsuppressed hospitals" Value="0" />
                        </Items>
                    </telerik:RadComboBox>
                </div>
            </div>


            <div style="margin-left: 10px; margin-top: 20px;" class="rptText">
                <asp:ObjectDataSource ID="HospitalObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess" SelectMethod="GetHospitalsLst">
                    <SelectParameters>
                        <asp:ControlParameter Name="HospitalName" ControlID="SearchTextBox" PropertyName="Text" ConvertEmptyStringToNull="false"  />
                        <asp:Parameter Name="Suppressed" Type="String" ConvertEmptyStringToNull="true" />
                    </SelectParameters>
                </asp:ObjectDataSource>
                <telerik:RadGrid ID="ReferringHospitalsRadGrid" runat="server" AutoGenerateColumns="false" OnNeedDataSource="ReferringHospitalsRadGrid_NeedDataSource" AllowMultiRowSelection="false" AllowSorting="true"
                     Skin="Metro" PageSize="50" AllowPaging="true" Style="margin-bottom: 10px; width: 95%; height: 500px;">
                    <HeaderStyle Font-Bold="true" />
                    <MasterTableView ShowHeadersWhenNoRecords="true" ClientDataKeyNames="HospitalID,HospitalName,Suppressed" DataKeyNames="HospitalID,HospitalName,Suppressed" TableLayout="Fixed" EnableNoRecordsTemplate="true" CssClass="MasterClass">
                        <Columns>
                            <telerik:GridTemplateColumn UniqueName="TemplateColumn" HeaderStyle-Width="150px">
                                <ItemTemplate>
                                    <asp:LinkButton ID="EditLinkButton" runat="server" Text="Edit" ToolTip="Edit Hospital" Font-Italic="true"></asp:LinkButton>
                                    &nbsp;&nbsp;
                                    <asp:LinkButton ID="SuppressLinkButton" runat="server" Text="Suppress" ToolTip="Suppress Hospital"
                                        Enabled="true" OnClientClick="return Show()"
                                        CommandName="SuppressHospital" Font-Italic="true"></asp:LinkButton>
                                </ItemTemplate>
                                <HeaderTemplate>
                                    <telerik:RadButton ID="AddNewHospitalButton" runat="server" Text="Add New Referring Hospital" Skin="Metro" OnClientClicked="addHospital" AutoPostBack="false" />
                                </HeaderTemplate>
                            </telerik:GridTemplateColumn>
                            <telerik:GridBoundColumn DataField="HospitalName" HeaderText="Hospital name" SortExpression="HospitalName" HeaderStyle-Width="160px" AllowSorting="true" ShowSortIcon="true" />
                            <telerik:GridBoundColumn DataField="Suppressed" HeaderText="Suppressed" SortExpression="Suppressed" HeaderStyle-Width="100px" />
                        </Columns>
                        <NoRecordsTemplate>
                            <div style="margin-top: 10px; margin-bottom: 10px; margin-left: 5px;" id="NoRecordsDiv" runat="server">
                                No hospitals found.
                            </div>
                        </NoRecordsTemplate>
                    </MasterTableView>
                    <PagerStyle Mode="NextPrev" PagerTextFormat="Navigate Pages {4} Page {0} of {1}; hospitals {2} to {3} of {5}" AlwaysVisible="true" />
                    <ClientSettings>
                        <Scrolling AllowScroll="true" UseStaticHeaders="true" />
                    </ClientSettings>
                </telerik:RadGrid>
            </div>
            <telerik:RadWindowManager ID="RadWindowManager1" runat="server" Skin="Metro" Modal="true" VisibleStatusbar="false">
                <Windows>
                    <telerik:RadWindow ID="HospitalRadWindow" runat="server" ReloadOnShow="true" KeepInScreenBounds="true" Width="400px" Height="140px" VisibleStatusbar="false" Title="Add Hospital">
                        <ContentTemplate>
                            <asp:HiddenField ID="HospitalIdHiddenField" runat="server" />
                            <telerik:RadFormDecorator runat="server" Skin="Metro" DecorationZoneID="NewHospitalWindow" DecoratedControls="All" />
                            <div style="padding-left: 10px" id="NewHospitalWindow">
                                <table cellpadding="5" cellspacing="5">
                                    <tr>
                                        <td>Hospital:</td>
                                        <td>
                                            <telerik:RadTextBox ID="NewHospitalTextBox" runat="server" Width="250px" />
                                            <asp:RequiredFieldValidator runat="server" ControlToValidate="NewHospitalTextBox" Text="*" ForeColor="Red" Display="Dynamic" ValidationGroup="NewHospital" />
                                        </td>
                                    </tr>
                                </table>
                            </div>
                            <div id="groupdiv" style="height: 10px; padding-top: 10px; padding-left: 10px; vertical-align: central; text-align: center;">
                                <telerik:RadButton ID="NewHospitalRadButton" runat="server" Text="Save" Skin="WebBlue" OnClick="NewHospitalRadButton_Click" ValidationGroup="NewHospital" />
                                &nbsp;
                            <telerik:RadButton ID="groupRadButton" runat="server" Text="Close" Skin="WebBlue" AutoPostBack="false" OnClientClicked="closeHospital" CausesValidation="false" />
                            </div>
                        </ContentTemplate>
                    </telerik:RadWindow>
                </Windows>
            </telerik:RadWindowManager>
        </div>
    </form>
</body>
</html>
