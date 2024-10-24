<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Options_RequiredFieldsSetup" Codebehind="RequiredFieldsSetup.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../Scripts/Global.js"></script>
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <link type="text/css" href="../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
        
    </style>

    <script type="text/javascript">
        $(window).on('load', function () {
        });

        $(document).ready(function () {

        });
    </script>
</head>

<body>
    <script type="text/javascript">
    </script>
    <form id="form1" runat="server">
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <div class="optionsHeading">Required Fields Setup</div>

        <asp:ObjectDataSource ID="ReqFieldsObjectDataSource" runat="server"
            TypeName="UnisoftERS.Options" SelectMethod="GetRequiredFields" UpdateMethod="UpdateRequiredFields">
            <SelectParameters>
                <asp:Parameter Name="ProcedureType" DbType="Int32" />
                <asp:Parameter Name="PageName" DbType="String" />
                <asp:Parameter Name="ClassName" DbType="String" />
                <asp:Parameter Name="Required" DbType="Boolean" />
                <asp:Parameter Name="CommonFields" DbType="Boolean" DefaultValue="true" />
            </SelectParameters>
            <UpdateParameters>
                <asp:Parameter Name="RequiredFieldId" DbType="Int32" />
                <asp:Parameter Name="Required" DbType="Boolean" />
            </UpdateParameters>
        </asp:ObjectDataSource>

        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" UpdateInitiatorPanelsOnly="true">
            <AjaxSettings>
                <telerik:AjaxSetting AjaxControlID="RequiredFieldsGrid">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="RequiredFieldsGrid" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
        </telerik:RadAjaxManager>

        <div style="margin-top: 5px; margin-left: 10px;" id="FormDiv" runat="server">

            <telerik:RadGrid ID="RequiredFieldsGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false"
                DataSourceID="ReqFieldsObjectDataSource" AllowFilteringByColumn="true"
                Skin="Office2010Blue" GridLines="None" PageSize="100" AllowPaging="true" Width="600px" Height="600px">
                <MasterTableView DataKeyNames="RequiredFieldId">
                    <Columns>
                        <telerik:GridBoundColumn DataField="PageName" HeaderText="Form" SortExpression="PageName" HeaderStyle-Width="80px">
                            <FilterTemplate>
                                <telerik:RadComboBox ID="PageNameComboBox" runat="server" AppendDataBoundItems="true" Skin="Windows7"
                                    OnClientSelectedIndexChanged="PageNameChanged"
                                    OnSelectedIndexChanged="PageNameComboBox_SelectedIndexChanged"
                                    OnPreRender="PageNameComboBox_PreRender">
                                </telerik:RadComboBox>
                                <telerik:RadScriptBlock ID="PageNameRadScriptBlock" runat="server">
                                    <script type="text/javascript">
                                        function PageNameChanged(sender, args) {
                                            var tableView = $find("<%# (DirectCast(Container, GridItem)).OwnerTableView.ClientID %>");
                                            tableView.filter("PageName", args.get_item().get_value(), "EqualTo");
                                        }
                                    </script>
                                </telerik:RadScriptBlock>
                            </FilterTemplate>
                        </telerik:GridBoundColumn>
                        <telerik:GridBoundColumn DataField="FieldName" HeaderText="Field" SortExpression="FieldName" HeaderStyle-Width="80px" AllowFiltering="false"></telerik:GridBoundColumn>
                        <telerik:GridTemplateColumn UniqueName="RequiredColumn" DataField="Required" HeaderText="Required" SortExpression="Required" HeaderStyle-Width="25px" AllowFiltering="false" ItemStyle-HorizontalAlign="Center" >
                            <ItemTemplate>
                                <asp:CheckBox ID="RequiredCheckBox" runat="server" AutoPostBack="true"
                                    Checked='<%# Bind("Required") %>' Enabled='<%# Not Eval("CannotBeSuppressed") %>'
                                    OnCheckedChanged="RequiredCheckBox_CheckedChanged" />
                            </ItemTemplate>
                        </telerik:GridTemplateColumn>
                    </Columns>
                </MasterTableView>
                <PagerStyle Mode="NextPrev" PagerTextFormat="Navigate Pages {4} Page {0} of {1}; Patients {2} to {3} of {5}"  />
                <ClientSettings EnablePostBackOnRowClick="true" EnableRowHoverStyle="true" >
                    <Selecting AllowRowSelect="True"  />
                    <Scrolling AllowScroll="true"  UseStaticHeaders="true" />
                </ClientSettings>
            </telerik:RadGrid>
        </div>
    </form>
</body>
</html>
