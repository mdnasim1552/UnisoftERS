<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Options_ReferingConsultant" Codebehind="ReferingConsultant.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

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

          function editConsultant(ConsultantID) {
              <%'var grid = $find("<%=ConsultantsRadGrid.ClientID").get_masterTableView().get_selectedItems()[0];%>
              if (ConsultantID > 0) {
                  <%'var id = grid.getDataKeyValue("ConsultantID");%>
                  radopen("EditConsultants.aspx?ConsultantID=" + ConsultantID, "Edit consultant", 700, 525);
                  return false;
              }
          }

<%--          function setSuppressed() {
              var supbtn = $find("<%= SuppressConsultant.ClientID%>")
                var grid = $find("<%= ConsultantsRadGrid.ClientID%>").get_masterTableView().get_selectedItems()[0]
                if (grid != null) {
                    var id = grid.getDataKeyValue("Suppressed");
                    if (id == 'No') {
                        supbtn.set_text("Suppress Consultant");
                    } else {
                        supbtn.set_text("Unsuppress Consultant");
                    }
                }
            }--%>
            function addConsultant() {
                radopen("EditConsultants.aspx", "Add consultant", 700, 525);
                return false;
            }
<%--            function ClientClosed() {
                $find("<%=ConsultantsRadGrid.ClientID%>").get_masterTableView().rebind()
                var supbtn = $find("<%= editConsultantButton.ClientID%>")
                supbtn.set_enabled(false);
                var supbtn = $find("<%= SuppressConsultant.ClientID%>")
                supbtn.set_enabled(false);
            }--%>

            function Show() {
                if (confirm("Are you sure you want to suppress this consultant?")) {
                    return true;
                }
                else {
                    return false;
                }
            }

            function refreshGrid(arg) {
                if (!arg) {
                   <%-- $find("<%= RadAjaxManager1.ClientID %>").ajaxRequest("Rebind");--%>
                    window.location.reload();
                }
                else {
                    $find("<%= RadAjaxManager1.ClientID %>").ajaxRequest("RebindAndNavigate");
                }
            }

<%--            function showSuppressedItems(sender, args) {
                document.getElementById('hiddenShowSuppressedItems').value = args.get_checked();
                var masterTable = $find("<%= ConsultantsRadGrid.ClientID%>").get_masterTableView();
                masterTable.rebind();
            }--%>
        </script>
    </telerik:RadScriptBlock>
</head>

<body>
    <script type="text/javascript">
    </script>
    <form id="form1" runat="server">
        <asp:HiddenField ID="hiddenShowSuppressedItems" runat="server" Value="0" />
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />

         <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest">
            <AjaxSettings>
                <telerik:AjaxSetting AjaxControlID="RadWindowManager1">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="ConsultantsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="ConsultantsRadGrid">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="ConsultantsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="HideSuppressButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="FormDiv" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="SuppressedComboBox">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="ConsultantsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="SearchButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="ConsultantsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1"  />
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
        </telerik:RadAjaxManager>
        
        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro">
        </telerik:RadAjaxLoadingPanel>

        <div class="optionsHeading">
            <asp:Label ID="HeadingLabel" runat="server" Text="Add/Edit referring consultants details"></asp:Label>
        </div>

        <telerik:RadFormDecorator  runat="server" DecoratedControls="All"  DecorationZoneID="FormDiv" Skin="Web20" />
        <asp:ObjectDataSource ID="ConsultantsObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess" SelectMethod="GetConsultantsLst">
            <SelectParameters>
                <asp:controlparameter  name="Field" controlid="SearchComboBox" propertyname="SelectedValue" DbType="String" />
                <asp:controlparameter name="FieldValue" controlid="SearchTextBox" propertyname="Text" DbType="String" />
                <asp:Parameter Name="Suppressed" DbType="Int32" />
                <%--<asp:ControlParameter Name="Suppressed" DbType="Int32" ControlID="chkSuppressed" ConvertEmptyStringToNull="true" />--%>
            </SelectParameters>
        </asp:ObjectDataSource>        
        <div id="FormDiv" runat="server" style="margin-top: 10px;">
            <div id="searchBox" runat="server" class="optionsBodyText" style="margin-left: 10px; width:556px">
                <asp:Panel ID="Panel1" runat="server" DefaultButton="SearchButton">
                    <table style="width:100%;">
                        <tr>
                            <td  style="padding-top:10px;padding-left:10px;width:15%;">
                                Search by:
                            </td>
                            <td style="padding-top:10px;padding-left:1px;width:35%;">
                                <telerik:RadComboBox ID="SearchComboBox" runat="server" Skin="Windows7" AutoPostBack="false"
                                    Font-Bold="False" Width="100%" CssClass="filterDDL" Filter="StartsWith">
                                    <Items >
                                        <telerik:RadComboBoxItem Text="All consultants"  Value ="" Selected="true"/>
                                        <telerik:RadComboBoxItem Text="Surname"  Value ="Surname"/>
                                        <telerik:RadComboBoxItem Text="Consultant name"  Value ="Name" />
                                        <telerik:RadComboBoxItem Text="Title"  Value ="Title" />
                                        <telerik:RadComboBoxItem Text="Speciality/Group"  Value ="Group"/>
                                    </Items>
                                </telerik:RadComboBox>
                            </td>
                            <td  style="padding:10px 10px 0px 10px;">
                                <telerik:RadTextBox ID="SearchTextBox" runat="server" Width="100%" EmptyMessage="Enter search text" Skin="Vista" CssClass="filterTxt" />
                            </td>
                            <td  style="padding:10px 10px 0px 10px;">
                                 <telerik:RadButton ID="SearchButton" runat="server" Text="Search" Font-Bold="true" Skin="Vista" CssClass="filterBtn" />
                            </td>
                        </tr>
                    </table> 
                </asp:Panel>
                <div  style="padding-top:10px;padding-left:12px;">
                    Show:
                    <telerik:RadComboBox ID="SuppressedComboBox" runat="server" Skin="Windows7" AutoPostBack="true" OnSelectedIndexChanged="HideSuppressButton_Click" CssClass="filterDDL">
                        <Items >
                            <telerik:RadComboBoxItem Text="All consultants" Value ="0" Selected="true"/>
                            <telerik:RadComboBoxItem Text="Suppressed consultants" Value ="1"/>
                            <telerik:RadComboBoxItem Text="Unsuppressed consultants" Value ="2" />
                        </Items>
                    </telerik:RadComboBox>
                </div>
            </div>

           
            <div style="margin-left: 10px; margin-top:20px;" class="rptText">
                    <telerik:RadGrid ID="ConsultantsRadGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false" AllowSorting="true"
                    DataSourceID="ConsultantsObjectDataSource" Skin="Metro" PageSize="50" AllowPaging="true" Style="margin-bottom: 10px;width:95%;height:500px;">
                    <HeaderStyle Font-Bold="true" />
                    <MasterTableView ShowHeadersWhenNoRecords="true" ClientDataKeyNames="ConsultantID,Suppressed" DataKeyNames="ConsultantID,Suppressed" TableLayout="Fixed" EnableNoRecordsTemplate="true" CssClass="MasterClass">
                        <Columns>
                            <telerik:GridTemplateColumn UniqueName="TemplateColumn" HeaderStyle-Width="150px">
                                <ItemTemplate>
                                    <asp:LinkButton ID="EditLinkButton" runat="server" Text="Edit" ToolTip="Edit Consultant" Font-Italic="true"  ></asp:LinkButton>
                                    &nbsp;&nbsp;
                                    <asp:LinkButton ID="SuppressLinkButton" runat="server" Text="Suppress" ToolTip="Suppress Consultant" 
                                        Enabled="true" OnClientClick="return Show()"
                                        CommandName="SuppressConsultant" Font-Italic="true"></asp:LinkButton>
                                </ItemTemplate>
                                <HeaderTemplate>
                                    <telerik:RadButton ID="AddNewConsultantButton" runat="server" Text="Add New Consultant" Skin="Windows7" OnClientClicked="addConsultant" AutoPostBack="false" />
                                </HeaderTemplate> 
                            </telerik:GridTemplateColumn>
                            <telerik:GridBoundColumn DataField="Name"  HeaderText="Consultant name" SortExpression="Name" HeaderStyle-Width="160px" AllowSorting="true" ShowSortIcon="true"/>                           
                            <telerik:GridBoundColumn DataField="Surname" HeaderText="Surname" SortExpression="Surname" HeaderStyle-Width="150px" AllowSorting="true" ShowSortIcon="true"/>
                            <telerik:GridBoundColumn DataField="GroupName" HeaderText="Speciality/Group" SortExpression="GroupName" HeaderStyle-Width="130px" ItemStyle-Wrap="true"/>
                             <telerik:GridBoundColumn DataField="Hospital" HeaderText="Hospital" SortExpression="Hospital" HeaderStyle-Width="150px"/>
                            <telerik:GridBoundColumn DataField="Suppressed" HeaderText="Suppressed" SortExpression="Suppressed" HeaderStyle-Width="100px"/>
                        </Columns>
                        <NoRecordsTemplate>
                            <div style="margin-top: 10px; margin-bottom: 10px; margin-left: 5px;" id="NoRecordsDiv" runat="server">
                                No consultant found.
                            </div>
                        </NoRecordsTemplate>
                       </MasterTableView>
                    <PagerStyle Mode="NextPrev" PagerTextFormat="Navigate Pages {4} Page {0} of {1}; consultants {2} to {3} of {5}" AlwaysVisible="true" CssClass="gridNavigation" />
                    <ClientSettings>
                        <Scrolling AllowScroll="true"  UseStaticHeaders="true" />
                    </ClientSettings>
                </telerik:RadGrid>
            </div>
            <telerik:RadWindowManager ID="RadWindowManager1" runat="server" Skin="Metro" Modal="true" VisibleStatusbar="false"  >
                    <Windows>
                       
                    </Windows>
                </telerik:RadWindowManager>
        </div>
    </form>
</body>
</html>
