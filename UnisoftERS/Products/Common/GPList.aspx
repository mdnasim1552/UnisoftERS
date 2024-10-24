<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="GPList.aspx.vb" Inherits="UnisoftERS.GPList" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Choose GP</title>
    <link href="../../Styles/Site.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../Scripts/Global.js"></script>
</head>
<body>
    <form id="mainForm" runat="server">
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />
        <telerik:RadCodeBlock ID="RadCodeBlock1" runat="server">
            <script type="text/javascript">
                function searchGP(sender, args) {
                    var searchBox = $find('<%= GPRadSearchBox.ClientID%>');
                    if (searchBox.get_text().length < 3) {
                        $find('<%=RadNotification1.ClientID%>').set_text("Enter a search term of more the 3 characters");
                        $find('<%=RadNotification1.ClientID%>').show();
                        arg.set_cancel(true);
                    }

                    //check minimum search characters
                    var searchBox = $find('<%= GPRadSearchBox.ClientID%>');
                    var searchContext = searchBox.get_searchContext();
                    var contextValue = "ALL";

                    if (searchContext.get_selectedItem() != undefined)
                        contextValue = searchContext.get_selectedItem().get_text();
                }


            </script>
        </telerik:RadCodeBlock>


        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server">
            <AjaxSettings>
                <telerik:AjaxSetting AjaxControlID="GPRadSearchBox">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="GPResultsGrid" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="GPResultsGrid">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="GPResultsGrid" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
        </telerik:RadAjaxManager>


        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro">
        </telerik:RadAjaxLoadingPanel>

        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
        <telerik:RadNotification ID="GPSaveCallBackNotification" runat="server" VisibleOnPageLoad="false" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Skin="Metro" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>" Position="Center" />
        <div id="FormDiv" runat="server" class="rptSummaryText10" style="margin-left: 5px; margin-top: 10px; padding-bottom: 10px;">
            <div style="padding: 10px;">
                <div style="padding: 10px;">
                    <telerik:RadSearchBox runat="server" ID="GPRadSearchBox"
                        CssClass="searchBox" Skin="Silk"
                        Width="200" DropDownSettings-Height="300"
                        EmptyMessage="Search GP"
                        Filter="Contains"
                        MaxResultCount="20" EnableAutoComplete="false" OnClientSearch="searchGP" OnSearch="GPRadSearchBox_Search" Localization-DefaultItemText="&nbsp;">
                        <SearchContext DropDownCssClass="contextDropDown">
                            <Items>
                                <telerik:SearchContextItem Text="GP Name" Key="1" Selected="true" />
                                <telerik:SearchContextItem Text="National Code" Key="2" />
                                <telerik:SearchContextItem Text="Practice Name" Key="3" />
                            </Items>
                        </SearchContext>
                    </telerik:RadSearchBox>
                </div>
                <telerik:RadGrid ID="GPResultsGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false"
                    Skin="Metro" PageSize="20" Width="100%" Height="200px" AllowPaging="true" Style="margin-bottom: 10px;" OnNeedDataSource="GPResultsGrid_NeedDataSource" OnItemCommand="GPResultsGrid_ItemCommand">
                    <HeaderStyle Font-Bold="true" />
                    <MasterTableView ShowHeadersWhenNoRecords="true" DataKeyNames="GPId, PracticeId" TableLayout="Fixed" EnableNoRecordsTemplate="true" CssClass="MasterClass">
                        <Columns>
                            <telerik:GridTemplateColumn UniqueName="TemplateColumn" HeaderStyle-Width="80px" AllowFiltering="false">
                                <ItemTemplate>
                                    <asp:LinkButton ID="SelectLinkButton" runat="server" Text="Select" ToolTip="Select this GP" Font-Italic="true" CommandName="select"></asp:LinkButton>
                                </ItemTemplate>
                            </telerik:GridTemplateColumn>
                            <telerik:GridBoundColumn DataField="CompleteName" HeaderText="GP Name" SortExpression="CompleteName" HeaderStyle-Width="150px">
                            </telerik:GridBoundColumn>
                            <telerik:GridBoundColumn DataField="GPCode" HeaderText="GP Code" SortExpression="GPCode" HeaderStyle-Width="90px">
                            </telerik:GridBoundColumn>
                            <telerik:GridBoundColumn DataField="Practice" HeaderText="Practice" SortExpression="Practice">
                            </telerik:GridBoundColumn>
                        </Columns>
                        <NoRecordsTemplate>
                            <div style="margin-top: 10px; margin-bottom: 10px; margin-left: 5px;" id="NoRecordsDiv" runat="server">
                                No GPs found. Amend your search criteria.
                            </div>
                        </NoRecordsTemplate>
                    </MasterTableView>
                    <PagerStyle Mode="NextPrev" PagerTextFormat="Navigate Pages {4} Page {0} of {1}; GPs {2} to {3} of {5}" AlwaysVisible="true" />
                    <ClientSettings EnablePostBackOnRowClick="true" EnableRowHoverStyle="true">
                        <Selecting AllowRowSelect="True" />
                        <Scrolling AllowScroll="true" UseStaticHeaders="true" />
                    </ClientSettings>

                </telerik:RadGrid>
            </div>
        </div>
    </form>
</body>
</html>
