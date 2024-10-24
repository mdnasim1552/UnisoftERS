<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Options_SystemUsage" Codebehind="SystemUsage.aspx.vb" %>

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
        <div class="optionsHeading">System Usage</div>

        <asp:ObjectDataSource ID="LoggedInUsersObjectDataSource" runat="server"
            TypeName="UnisoftERS.Options" SelectMethod="GetLoggedInUsers" DeleteMethod="RemoveLoggedInUser">
             <SelectParameters>
                <asp:SessionParameter DefaultValue="0"  Name="operatingHospitalIds" SessionField="OperatingHospitalIdsForTrust" type="string" />
            </SelectParameters>
            <DeleteParameters>
                <asp:Parameter Name="userId" DbType="Int32" />
            </DeleteParameters>
        </asp:ObjectDataSource>

        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" UpdateInitiatorPanelsOnly="true">
            <AjaxSettings>
                <telerik:AjaxSetting AjaxControlID="LoggedInUsersGrid">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="LoggedInUsersGrid" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="LoggedInUsersGrid">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="LockedPatientsGrid">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="LockedPatientsGrid" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="LockedPatientsGrid">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
        </telerik:RadAjaxManager>

        <div id="FormDiv" runat="server" style="margin-left: 10px;">
            <div style="margin-top: 5px;">
                <div class="optionsSubHeading" style="font-size:1.0em; ">
                    Logged In Users
                </div>
                <telerik:RadGrid ID="LoggedInUsersGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false"
                    DataSourceID="LoggedInUsersObjectDataSource" AllowAutomaticDeletes="True"
                    Skin="Metro" GridLines="None" PageSize="50" AllowPaging="true" Width="600px">
                    <MasterTableView DataKeyNames="UserId" TableLayout="Fixed">
                        <Columns>
                            <telerik:GridBoundColumn DataField="Username" HeaderText="User ID" SortExpression="Username" HeaderStyle-Width="50px"></telerik:GridBoundColumn>
                            <telerik:GridBoundColumn DataField="User" HeaderText="User" SortExpression="User" HeaderStyle-Width="80px"></telerik:GridBoundColumn>
                            <telerik:GridBoundColumn DataField="LastLoggedIn" HeaderText="Logged in at" SortExpression="LastLoggedIn" HeaderStyle-Width="50px"></telerik:GridBoundColumn>
                            <telerik:GridBoundColumn DataField="IsReadOnly" HeaderText="Readonly" SortExpression="IsReadOnly" HeaderStyle-Width="30px"></telerik:GridBoundColumn>
                            <%--<telerik:GridButtonColumn CommandName="Delete" Text="Logoff" ImageUrl="~/Images/NewLogo_138_58.png" 
                                                ConfirmText="Are you sure you want to logout this user?" HeaderStyle-Width="20px"></telerik:GridButtonColumn>--%>
                            <telerik:GridTemplateColumn UniqueName="DeleteTemplateColumn" ItemStyle-HorizontalAlign="Center" HeaderText="Logoff" HeaderStyle-Width="20px">
                                <ItemTemplate>
                                    <asp:ImageButton ID="LogOutImageButton" runat="server" ImageUrl="~/Images/Log Out_24x24.png" CommandName="Delete" ToolTip="Remove this login"
                                        OnClientClick="javascript:if(!confirm('Are you sure you want to logout this user?')){return false;}" Height="20px" Width="20px" />
                                </ItemTemplate>
                            </telerik:GridTemplateColumn>
                        </Columns>
                        <NoRecordsTemplate>
                            <div style="margin-top: 10px; margin-bottom: 10px; margin-left: 5px;">
                                No users currently logged in
                            </div>
                        </NoRecordsTemplate>
                    </MasterTableView>
                </telerik:RadGrid>
            </div>

      <%--       <asp:ObjectDataSource ID="LockedPatientsObjectDataSource" runat="server"
                TypeName="UnisoftERS.Options" SelectMethod="GetLockedPatients" DeleteMethod="UpdateLockedPatients">
                <DeleteParameters>
                    <asp:Parameter Name="patientId" DbType="Int32" />
                </DeleteParameters>
            </asp:ObjectDataSource>

           <div style="margin-top: 50px;">
                <div class="optionsSubHeading" style="font-size:1.0em;">
                    Locked Patient Records
                </div>
                <telerik:RadGrid ID="LockedPatientsGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false"
                    DataSourceID="LockedPatientsObjectDataSource" AllowAutomaticDeletes="True"
                    Skin="Office2010Blue" GridLines="None" PageSize="50" AllowPaging="true" Width="600px">
                    <MasterTableView DataKeyNames="PatientId" TableLayout="Fixed">
                        <Columns>
                            <telerik:GridBoundColumn DataField="PatientName" HeaderText="Patient" SortExpression="PatientName" HeaderStyle-Width="80px"></telerik:GridBoundColumn>
                            <telerik:GridBoundColumn DataField="LockedBy" HeaderText="Locked By" SortExpression="LockedBy" HeaderStyle-Width="100px"></telerik:GridBoundColumn>
                            <telerik:GridBoundColumn DataField="LockedOn" HeaderText="Locked On" SortExpression="LockedOn" HeaderStyle-Width="50px"></telerik:GridBoundColumn>
                            <telerik:GridTemplateColumn UniqueName="UnlockTemplateColumn" ItemStyle-HorizontalAlign="Center" HeaderText="Unlock" HeaderStyle-Width="25px">
                                <ItemTemplate>
                                    <asp:ImageButton ID="UnlockImageButton" runat="server" ImageUrl="~/Images/Lock-Unlock-48x48.png" CommandName="Delete" ToolTip="Unlock this record"
                                        OnClientClick="javascript:if(!confirm('Are you sure you want to unlock this patient?')){return false;}"
                                        Height="20px" Width="20px" />
                                </ItemTemplate>
                            </telerik:GridTemplateColumn>
                        </Columns>
                        <NoRecordsTemplate>
                            <div style="margin-top: 10px; margin-bottom: 10px; margin-left: 5px;">
                                No patient records are currently being used (locked)
                            </div>
                        </NoRecordsTemplate>
                    </MasterTableView>
                </telerik:RadGrid>
            </div>--%>
        </div>
    </form>
</body>
</html>
