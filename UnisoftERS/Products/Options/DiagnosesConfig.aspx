<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Options_DiagnosesConfig" Codebehind="DiagnosesConfig.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../Scripts/Global.js"></script>
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <link type="text/css" href="../../Styles/Site.css" rel="stylesheet" />
    <style>
        .MasterClass .rgCaption 
        {    
            color: #026BB9; 
            background-color:#f9f9f9; 
            border-bottom:1px solid #eae7e7;
            font: 1.3em 'Segoe UI', Arial, sans-serif;
        } 
    </style>
</head>

<body>
    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <script type="text/javascript">
            $(window).on('load', function () {
            });

            $(document).ready(function () {

            });


            function ClientNodeClicked(sender, eventArgs) {
                var node = eventArgs.get_node();
                if (node.get_nodes().get_count() == 0) {
                }
                else {
                    node.expand();
                    node.get_allNodes()[0].select();
                }
            }

            function refreshGrid(arg) {
                if (!arg) {
                    $find("<%= RadAjaxManager1.ClientID %>").ajaxRequest("Rebind");
               }
               else {
                   $find("<%= RadAjaxManager1.ClientID %>").ajaxRequest("RebindAndNavigate");
               }
           }
           function openAddRoleWindow(roleId) {
               var tree = $find("<%= DiagnosesRadTreeView.ClientID%>");
                var node = tree.get_selectedNode()
                var pr = "";
                var ch = "";
                if (node != null) {
                    if (node.get_level() != 0) {
                        pr = node.get_parent().get_value();
                        ch = node.get_value();
                    } else {
                        pr = node.get_value();
                        ch = "";
                    }

                }
                if (roleId > 0) {
                    radopen("EditDiagnoses.aspx?DiagID=" + roleId + "&Pnode=" + pr + "&Cnode=" + ch, "", 400, 330);
                } else {
                    radopen("EditDiagnoses.aspx?Pnode=" + pr + "&Cnode=" + ch, "", 400, 330);
                }

            }
        </script>
    </telerik:RadScriptBlock>
    <form id="form1" runat="server">       
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />

        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server">
            <AjaxSettings>
                <telerik:AjaxSetting AjaxControlID="RadAjaxManager1">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="DiagnosesRadGrid"  LoadingPanelID="RadAjaxLoadingPanel1"/>
                    </UpdatedControls>
                </telerik:AjaxSetting>
                 <telerik:AjaxSetting AjaxControlID="DiagnosesRadTreeView">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="DiagnosesRadGrid"  LoadingPanelID="RadAjaxLoadingPanel1"/>
                    </UpdatedControls>
                </telerik:AjaxSetting>
                            </AjaxSettings>
        </telerik:RadAjaxManager>

        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro" />

        <telerik:RadFormDecorator ID="UserMaintenanceRadFormDecorator" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
        <asp:ObjectDataSource ID="DiagnosesObjectDataSource" runat="server" TypeName="UnisoftERS.OtherData" SelectMethod="DiagnosesSelect">
            <SelectParameters>
               <asp:Parameter Name="ProcedureTypeID"  DbType="Int32"/>
                <asp:Parameter Name="Section"  DbType="String" DefaultValue=""  ConvertEmptyStringToNull="False" />
            </SelectParameters>
        </asp:ObjectDataSource>
        <div class="text12" style="padding-top: 10px; padding-bottom: 10px">Diagnoses configuration</div>
        <div id="FormDiv" runat="server" style="position: relative; padding-left: 10px">
            <telerik:RadSplitter ID="RadSplitter1" runat="server" Width="640px" Height="600px" Orientation="Vertical" Skin="Office2010Blue">
                <telerik:RadPane ID="RadPane1" runat="server" Width="150px" BackColor="#DEF3F8" CssClass="radPane" >
                    <telerik:RadTreeView ID="DiagnosesRadTreeView" runat="server" Height="100%" Skin="WebBlue" OnNodeClick="RadTreeView1_NodeClick" OnClientNodeClicked="ClientNodeClicked">
                    </telerik:RadTreeView>
                </telerik:RadPane>
                <telerik:RadPane ID="RadPane2" runat="server" Width="700px">
                    <telerik:RadGrid ID="DiagnosesRadGrid" runat="server"  AllowPaging="True" 
                        AllowSorting="True" Skin="Office2010Blue" Width="600px" GroupPanelPosition="Top" AutoGenerateColumns="False"
                        PageSize="15" AllowMultiRowSelection="false" OnNeedDataSource="DiagnosesRadGrid_NeedDataSource">
                        <HeaderStyle Font-Bold="true" Height="25" />
                        <MasterTableView ShowHeadersWhenNoRecords="true" DataKeyNames="DiagnosesMatrixID" ClientDataKeyNames="DiagnosesMatrixID" CssClass="MasterClass">
                            <Columns>
                                <telerik:GridTemplateColumn UniqueName="TemplateColumn">
                                    <ItemTemplate>
                                        <%-- <telerik:RadButton ID="editButton" runat="server" Text="edit" Skin="Windows7" AutoPostBack="false" />--%>
                                        <asp:LinkButton ID="EditLinkButton" runat="server" Text="Edit" Width="40px" CommandName="Edit"></asp:LinkButton>
                                    </ItemTemplate>
                                    <HeaderTemplate>
                                        <telerik:RadButton ID="AddNewDiagnosesButton" runat="server" Text="Add New" Skin="Windows7" OnClientClicked="openAddRoleWindow" AutoPostBack="false" />
                                    </HeaderTemplate>
                                </telerik:GridTemplateColumn>
                                <telerik:GridBoundColumn UniqueName="DisplayName" DataField="DisplayName" HeaderText="Name" SortExpression="DisplayName" HeaderStyle-Width="320px"></telerik:GridBoundColumn>
                                <telerik:GridBoundColumn DataField="EndoCode" HeaderText="Endoscopy Code" SortExpression="EndoCode" HeaderStyle-Width="100px"></telerik:GridBoundColumn>
                                <telerik:GridBoundColumn DataField="Disabled" HeaderText="Disabled?" SortExpression="Disabled" HeaderStyle-Width="100px"></telerik:GridBoundColumn>
                                <telerik:GridBoundColumn DataField="OrderByNumber" HeaderText="Order By Number" SortExpression="OrderByNumber" HeaderStyle-Width="100px"></telerik:GridBoundColumn>
                            </Columns>
                            <NoRecordsTemplate>
                                <div style="margin-left: 5px;">No records found</div>
                            </NoRecordsTemplate>
                        </MasterTableView>
                        <ClientSettings Selecting-AllowRowSelect="true" />
                        <SelectedItemStyle BackColor="Fuchsia" BorderColor="Purple" BorderStyle="Dashed" BorderWidth="1px" />
                        <ItemStyle Height="30" />
                        <AlternatingItemStyle Height="30" />
                        <PagerStyle Mode="NumericPages"></PagerStyle>
                    </telerik:RadGrid>
                </telerik:RadPane>
            </telerik:RadSplitter>            
        </div>  
        <telerik:RadWindowManager ID="manager" runat="server"  ReloadOnShow="true" Modal="true" Skin="Metro" Behaviors="Close" VisibleStatusbar="false" >
        </telerik:RadWindowManager>      
    </form>
</body>
</html>
