<%@ Page Language="VB" MasterPageFile="~/Templates/Scheduler.master" AutoEventWireup="false" Inherits="UnisoftERS.Products_Options_Scheduler_Templates" CodeBehind="Templates.aspx.vb" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContentPlaceHolder" runat="Server">

    <title>Add/Edit scheduler templates</title>
    <script type="text/javascript" src="../../../Scripts/jquery-2.2.4.min.js"></script>
    <script type="text/javascript" src="../../../Scripts/Global.js"></script>
    <link type="text/css" href="../../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
    </style>

    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <script type="text/javascript">
            function editTemplate(TemplateID) {
                if (TemplateID > 0) {
                    var ownd = radopen("EditTemplates.aspx?ListRulesId=" + TemplateID, "Edit Template", 700, 655);
                    ownd.set_visibleStatusbar(false);
                    return false;
                }
            }

            function addTemplate() {
                var ownd = radopen("EditTemplates.aspx", "Add Template", 700, 655);
                ownd.set_visibleStatusbar(false);
                return false;
            }

            function checkAndSuppressTemplate(TemplateID, suppressFromDate) {
                if (confirm("This template contains bookings up until " + suppressFromDate + ". Do you wish to suppress the template after this date?")) {
                    $.ajax({
                        type: "POST",
                        url: "Templates.aspx/SuppressTemplate",
                        data: JSON.stringify({ "templateId": TemplateID, suppress: true, "suppressFrom": suppressFromDate }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (data) {
                            var masterTable = $find("<%= TemplatesRadGrid.ClientID %>").get_masterTableView();
                             var arg
                             masterTable.fireCommand("RebindAndNavigate", arg);
                         }
                     });

                    return true;
                }
                else {
                    return false;
                }
            }

            function Show(TemplateID, isSuppressed) {
                var confirmMessage = (isSuppressed == "suppress") ? "Are you sure you want to suppress this Template?" : "Are you sure you want to unsuppress this Template?";

                if (confirm(confirmMessage)) {
                    $.ajax({
                        type: "POST",
                        url: "Templates.aspx/SuppressTemplate",
                        data: JSON.stringify({ "templateId": TemplateID, "suppress": isSuppressed, "suppressFrom": null }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (data) {
                            var masterTable = $find("<%= TemplatesRadGrid.ClientID %>").get_masterTableView();
                            var arg
                            masterTable.fireCommand("RebindAndNavigate", arg);
                        }
                    });

                    return true;
                }
                else {
                    return false;
                }
            }

            function refreshGrid(arg) {
                var masterTable = $find("<%= TemplatesRadGrid.ClientID %>").get_masterTableView();                

                if (masterTable != null) {                    
                    if (!arg) {                
                        masterTable.fireCommand("Rebind", arg);
                    }
                    else {                             
                        masterTable.fireCommand("RebindAndNavigate", arg);                           
                    }
                }
                else {                    
                    window.reload();
                }                
            }
        </script>
    </telerik:RadScriptBlock>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyContentPlaceHolder" runat="Server">

    <asp:HiddenField ID="hiddenShowSuppressedItems" runat="server" Value="0" />
    <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Metro" />
    <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />

    <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro">
    </telerik:RadAjaxLoadingPanel>

    <div class="optionsHeading">
        <asp:Label ID="HeadingLabel" runat="server" Text="Scheduler template maintenance"></asp:Label>
    </div>

    <telerik:RadFormDecorator runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Metro" />
    <asp:ObjectDataSource ID="TemplatesObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="GetTemplatesLst">
        <SelectParameters>
            <asp:Parameter Name="Field" DbType="String" DefaultValue="" />
            <asp:Parameter Name="FieldValue" DbType="String" DefaultValue="" />
            <asp:Parameter Name="Suppressed" DbType="Int32" />
            <asp:Parameter Name="IsGI" DbType="Int32" DefaultValue="1" />
        </SelectParameters>
    </asp:ObjectDataSource>
    <div id="FormDiv" runat="server" style="margin-top: 10px; height: 100%">
        <div id="searchBox" runat="server" class="optionsBodyText" style="margin-left: 10px; width: 556px">
            <asp:Panel ID="Panel1" runat="server" DefaultButton="SearchButton" Visible="false">
                <table style="width: 100%;">
                    <tr>
                        <td style="padding-top: 10px; padding-left: 10px; width: 15%;">Search by:
                        </td>
                        <td style="padding-top: 10px; padding-left: 1px; width: 35%;">
                            <telerik:RadComboBox ID="SearchComboBox" runat="server" Skin="Metro" AutoPostBack="false"
                                Font-Bold="False" Width="100%" CssClass="filterDDL">
                                <Items>
                                    <telerik:RadComboBoxItem Text="All templates" Value="" Selected="true" />
                                    <telerik:RadComboBoxItem Text="List Name" Value="ListName" />
                                    <telerik:RadComboBoxItem Text="Endoscopist" Value="Endoscopist" />
                                </Items>
                            </telerik:RadComboBox>
                        </td>
                        <td style="padding: 10px 10px 0px 10px;">
                            <telerik:RadTextBox ID="SearchTextBox" runat="server" Width="100%" EmptyMessage="Enter search text" Skin="Metro" CssClass="filterTxt" />
                        </td>
                        <td style="padding: 10px 10px 0px 10px;">
                            <telerik:RadButton ID="SearchButton" runat="server" Text="Search" Font-Bold="true" Skin="Metro" CssClass="filterBtn" />
                        </td>
                    </tr>
                </table>
            </asp:Panel>
            <table>
                <tr>
                    <td>
                        <div style="padding-top: 10px; padding-left: 12px;">
                            Show:
                    <telerik:RadComboBox ID="SuppressedComboBox" runat="server" Skin="Metro" AutoPostBack="true" OnSelectedIndexChanged="HideSuppressButton_Click" CssClass="filterDDL">
                        <Items>
                            <telerik:RadComboBoxItem Text="All templates" Value="0" Selected="true" />
                            <telerik:RadComboBoxItem Text="Suppressed templates" Value="1" />
                            <telerik:RadComboBoxItem Text="Unsuppressed templates" Value="2" />
                        </Items>
                    </telerik:RadComboBox>
                        </div>
                    </td>

                    <td></td>
                </tr>
            </table>
        </div>

        <div style="margin: 20px 10px 0 10px; height: 100%" class="rptText">
            <telerik:RadGrid ID="TemplatesRadGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false" AllowSorting="true" 
                DataSourceID="TemplatesObjectDataSource" Skin="Metro" PageSize="50" AllowPaging="false" Style="width: 100%;height:78vh">
                <HeaderStyle Font-Bold="true" />
                <MasterTableView EnableViewState="false" ShowHeadersWhenNoRecords="true" ClientDataKeyNames="ListRulesId,Suppressed" DataKeyNames="ListRulesId,Suppressed" TableLayout="Fixed" EnableNoRecordsTemplate="true" CssClass="MasterClass">
                    <Columns>
                        <telerik:GridTemplateColumn UniqueName="TemplateColumn" HeaderStyle-Width="150px">
                            <ItemTemplate>
                                <asp:LinkButton ID="EditLinkButton" runat="server" Text="Edit" ToolTip="Edit Template" Font-Italic="true"></asp:LinkButton>
                                &nbsp;&nbsp;
                                    <asp:LinkButton ID="SuppressLinkButton" runat="server" Text="Suppress" ToolTip="Suppress Template"
                                        Enabled="true"
                                        CommandName="SuppressTemplate" Font-Italic="true"></asp:LinkButton>
                            </ItemTemplate>
                            <HeaderTemplate>
                                <telerik:RadButton ID="AddNewTemplateButton" runat="server" Text="Add New Template" Skin="Metro" OnClientClicked="addTemplate" AutoPostBack="false" />
                            </HeaderTemplate>
                        </telerik:GridTemplateColumn>
                        <telerik:GridBoundColumn DataField="ListName" HeaderText="Template name" SortExpression="ListName" HeaderStyle-Width="160px" AllowSorting="true" ShowSortIcon="true" />
                        <telerik:GridBoundColumn DataField="HospitalName" HeaderText="Hospital Name" SortExpression="HospitalName" HeaderStyle-Width="150px" AllowSorting="true" ShowSortIcon="true" />
                        <telerik:GridBoundColumn DataField="ProcType" HeaderText="List type" SortExpression="ProcType" HeaderStyle-Width="130px" ItemStyle-Wrap="true" />
                        <telerik:GridBoundColumn DataField="IsTraining" HeaderText="Training" SortExpression="IsTraining" HeaderStyle-Width="150px" />
                        <telerik:GridBoundColumn DataField="Points" HeaderText="No of points" SortExpression="Points" HeaderStyle-Width="100px" />
                    </Columns>
                    <NoRecordsTemplate>
                        <div style="margin-top: 10px; margin-bottom: 10px; margin-left: 5px;" id="NoRecordsDiv" runat="server">
                            No Template found.
                        </div>
                    </NoRecordsTemplate>
                </MasterTableView>
                <PagerStyle Mode="NextPrev" PagerTextFormat="Navigate Pages {4} Page {0} of {1}; templates {2} to {3} of {5}" AlwaysVisible="true" />
                <ClientSettings>
                    <Scrolling AllowScroll="true" UseStaticHeaders="true" />                    
                </ClientSettings>
            </telerik:RadGrid>
        </div>
        <telerik:RadWindowManager ID="RadWindowManager1" runat="server" Skin="Metro" Modal="true" VisibleStatusbar="false">
            <Windows>
            </Windows>
        </telerik:RadWindowManager>
    </div>
</asp:Content>
