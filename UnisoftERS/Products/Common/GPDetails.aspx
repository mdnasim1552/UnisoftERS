<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Common_GPDetails" CodeBehind="GPDetails.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../../Styles/Site.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../Scripts/Global.js"></script>
</head>
<body>
    <form id="mainForm" runat="server">
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />
        <telerik:RadCodeBlock ID="RadCodeBlock1" runat="server">
            <script type="text/javascript">
                function CheckForValidPage(button) {
                    var valid = Page_ClientValidate("SaveGP");
                    if (!valid) {
                        $find("<%=SaveGPRadNotification.ClientID%>").show();
                    }
                }

                function searchGP(sender, args) {
                    var searchBox = $find('<%= GPRadSearchBox.ClientID%>');
                     var searchContext = searchBox.get_searchContext();
                     var contextValue = "ALL";

                     if (searchContext.get_selectedItem() != undefined)
                         contextValue = searchContext.get_selectedItem().get_text();

               <%-- if ((searchBox.get_text().trim() != "")) {
                    var url = "<%= ResolveUrl("~/Products/Common/GPDetails.aspx?searchstr={0}&searchval={1}")%>";
                    url = url.replace("{0}", searchBox.get_text().trim());
                    url = url.replace("{1}", contextValue);

                    var oWnd = $find("<%= EditGPWindow.ClientID %>");
                    oWnd._navigateUrl = url
                    oWnd.set_title("Choose GP");
                    oWnd.SetSize(700, 500);

                    //Add the name of the function to be executed when RadWindow is closed.
                    oWnd.add_close(OnClientClose);
                    oWnd.show();
                }--%>
                }


            </script>
        </telerik:RadCodeBlock>
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
        <telerik:RadNotification ID="GPSaveCallBackNotification" runat="server" VisibleOnPageLoad="false" Skin="Web20" />
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="650px" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Height="240px">
                <div id="FormDiv" runat="server" class="rptSummaryText10" style="margin-left: 5px; margin-top: 10px; padding-bottom: 10px;">
                    <table id="EditGPTable" runat="server">
                        <tr>
                            <td style="width: 50%;">
                                <table>
                                    <tr>
                                        <td style="width: 100px;">Title:</td>
                                        <td>
                                            <telerik:RadTextBox ID="EditGPTitleTextBox" runat="server" Width="60" />
                                            <asp:RequiredFieldValidator ID="GPTitleRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                                                ControlToValidate="EditGPTitleTextBox" EnableClientScript="true" Display="Dynamic"
                                                ErrorMessage="Title is required" Text="*" ToolTip="This is a required field"
                                                ValidationGroup="SaveGP">
                                            </asp:RequiredFieldValidator>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Initials:</td>
                                        <td>
                                            <telerik:RadTextBox ID="EditGPInitialsTextBox" runat="server" Width="60" />
                                            <asp:RequiredFieldValidator ID="GPInitialsRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                                                ControlToValidate="EditGPInitialsTextBox" EnableClientScript="true" Display="Dynamic"
                                                ErrorMessage="Initials is required" Text="*" ToolTip="This is a required field"
                                                ValidationGroup="SaveGP">
                                            </asp:RequiredFieldValidator>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Fore name(s):</td>
                                        <td>
                                            <telerik:RadTextBox ID="EditGPForeNameTextBox" runat="server" Width="160" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Surname:</td>
                                        <td>
                                            <telerik:RadTextBox ID="EditGPSurnameTextBox" runat="server" Width="160" />
                                            <asp:RequiredFieldValidator ID="GPSurnameRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                                                ControlToValidate="EditGPSurnameTextBox" EnableClientScript="true" Display="Dynamic"
                                                ErrorMessage="Surname is required" Text="*" ToolTip="This is a required field"
                                                ValidationGroup="SaveGP">
                                            </asp:RequiredFieldValidator>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Suppressed:</td>
                                        <td>
                                            <asp:CheckBox ID="EditGPSuppressedCheckBox" runat="server" Text=""
                                                Style="margin-left: -3px;" Skin="WebBlue" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                            <td style="width: 10px;"></td>
                            <td>
                                <table>
                                    <tr>
                                        <td style="width: 100px;">Practice Name:</td>
                                        <td>
                                            <telerik:RadTextBox ID="EditGPPracticeNameTextBox" runat="server" Width="160" />
                                        </td>
                                    </tr>
                                    <tr style="vertical-align: top;">
                                        <td>Address:</td>
                                        <td>
                                            <telerik:RadTextBox ID="EditGPAddressTextBox" runat="server" Width="160" Height="70" TextMode="MultiLine" />
                                            <asp:RequiredFieldValidator ID="GPAddressRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                                                ControlToValidate="EditGPAddressTextBox" EnableClientScript="true" Display="Dynamic"
                                                ErrorMessage="Address is required" Text="*" ToolTip="This is a required field"
                                                ValidationGroup="SaveGP">
                                            </asp:RequiredFieldValidator>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Telephone:</td>
                                        <td>
                                            <telerik:RadTextBox ID="EditGPTelephoneTextBox" runat="server" Width="120" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td style="height: 5px;"></td>
                        </tr>
                        <tr>
                            <td colspan="2">
                                <div id="buttonsdiv" style="height: 10px; padding-top: 6px; vertical-align: central;">
                                    <telerik:RadButton ID="SaveGPButton" runat="server" Text="Save" Skin="Web20"
                                        ValidationGroup="SaveGP" OnClientClicked="CheckForValidPage" />
                                    <telerik:RadButton ID="CancelGPButton" runat="server" Text="Close" Skin="Web20"
                                        AutoPostBack="false" OnClientClicked="CloseWindow" />
                                </div>
                            </td>
                        </tr>
                    </table>
                </div>

                <telerik:RadNotification ID="SaveGPRadNotification" runat="server" Animation="None"
                    EnableRoundedCorners="true" EnableShadow="true" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
                    LoadContentOn="PageLoad" TitleIcon="delete" Position="Center" Style="color: blue;"
                    AutoCloseDelay="70000">
                    <ContentTemplate>
                        <asp:ValidationSummary ID="SaveGPValidationSummary" runat="server" ValidationGroup="SaveGP" DisplayMode="BulletList"
                            EnableClientScript="true" BorderStyle="None" BackColor="Transparent" CssClass="aspxValidationSummary"></asp:ValidationSummary>
                    </ContentTemplate>
                </telerik:RadNotification>

            </telerik:RadPane>
            <telerik:RadPane ID="GPListRadPane" runat="server" Visible="false" Height="540px">
                <div style="padding: 10px;">
                    <div style="padding: 10px;">
                        New search:&nbsp;
                         <telerik:RadSearchBox runat="server" ID="GPRadSearchBox"
                             CssClass="searchBox" Skin="Silk"
                             Width="200" DropDownSettings-Height="300"
                             EmptyMessage="Search GP"
                             Filter="Contains"
                             MaxResultCount="20" EnableAutoComplete="false" OnClientSearch="searchGP" Localization-DefaultItemText="&nbsp;">
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
                        Skin="Metro" PageSize="20" Width="100%" AllowPaging="true" Style="margin-bottom: 10px;" OnItemCommand="GPResultsGrid_ItemCommand">
                        <HeaderStyle Font-Bold="true" />
                        <MasterTableView ShowHeadersWhenNoRecords="true" DataKeyNames="GPId" TableLayout="Fixed" EnableNoRecordsTemplate="true" CssClass="MasterClass">
                            <Columns>
                                <telerik:GridTemplateColumn UniqueName="TemplateColumn" HeaderStyle-Width="80px" AllowFiltering="false">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="SelectLinkButton" runat="server" Text="Select" ToolTip="Select this GP" Font-Italic="true"></asp:LinkButton>
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridBoundColumn DataField="CompleteName" HeaderText="GP Name" SortExpression="CompleteName" HeaderStyle-Width="150px">
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
            </telerik:RadPane>
        </telerik:RadSplitter>

        <telerik:RadAjaxManager ID="GPDetailsAjaxManager" runat="server">
            <AjaxSettings>
                <telerik:AjaxSetting AjaxControlID="EditGPNameComboBox">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="EditGPTable" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="SaveGPButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="GPSaveCallBackNotification" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
        </telerik:RadAjaxManager>
    </form>
</body>
</html>
