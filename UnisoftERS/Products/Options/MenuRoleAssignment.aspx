<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Options_MenuRoleAssignment" Codebehind="MenuRoleAssignment.aspx.vb" %>

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

    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <script type="text/javascript">
            $(window).on('load', function () {
            });

            $(document).ready(function () {
            });
      </script>
    </telerik:RadScriptBlock>
</head>

<body>
    <script type="text/javascript">
    </script>
    <form id="form1" runat="server">
       <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
        <telerik:RadNotification ID="PagesByRoleNotification" runat="server" VisibleOnPageLoad="false" />

        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro"/>
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server">
            <AjaxSettings>
               <telerik:AjaxSetting AjaxControlID="MenuCategoryDropDownList">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="MenuRadGrid"></telerik:AjaxUpdatedControl>                         
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="SaveButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="PagesByRoleNotification"></telerik:AjaxUpdatedControl>  
                        <telerik:AjaxUpdatedControl ControlID="MenuRadGrid"></telerik:AjaxUpdatedControl>                         
                    </UpdatedControls>
                </telerik:AjaxSetting>
                </AjaxSettings>
            </telerik:RadAjaxManager>
        <div class="optionsHeading">Menu Assignment</div>        
        <asp:ObjectDataSource ID="MenuObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess" SelectMethod="GetMenuByCategory" >
            <SelectParameters>
                <asp:ControlParameter Name="MenuCategory" ControlID="MenuCategoryDropDownList" PropertyName="SelectedText" DbType="String"/>                
            </SelectParameters>
        </asp:ObjectDataSource>
        <asp:ObjectDataSource ID="PageObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess" SelectMethod="GetDistinctListPage" />
        <asp:ObjectDataSource ID="CategoryObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess" SelectMethod="GetDistinctCategory" />
          <div id="FormDiv" runat="server">
            <div style="margin-top: 5px; margin-left: 10px;" class="optionsBodyText">

                <div style="margin-top: 15px;">
                    <table>
                        <tr>
                            <td>Select Menu Category:
                                <telerik:RadDropDownList ID="MenuCategoryDropDownList" runat="server"  Width="200px" Skin="Windows7" AutoPostBack="true" DataSourceID="CategoryObjectDataSource" DataValueField="MenuCategory" DataTextField="MenuCategory"/>                                   
                                  
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div class="optionsSubHeading" style="padding-bottom:5px;">Menu</div>
                                <div style="height:450px;width:700px;display: block;overflow:auto;">
                                    <telerik:RadGrid ID="MenuRadGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false"
                                        DataSourceID="MenuObjectDataSource" AllowSorting="true" 
                                        CellSpacing="0" GridLines="None"  Skin="Office2010Blue" Width="650px" Height="440px">
                                        <HeaderStyle Font-Bold="true" Height="12px" />
                                        <MasterTableView ShowHeadersWhenNoRecords="true" DataKeyNames="MapID" ClientDataKeyNames="MapID">
                                            <Columns>
                                                <telerik:GridBoundColumn DataField="MapID" HeaderText="MapID" SortExpression="MapID" Visible="false"  ></telerik:GridBoundColumn>
                                                <telerik:GridBoundColumn DataField="NodeName" HeaderText="Menu Name" SortExpression="NodeName" HeaderStyle-Width="300px"></telerik:GridBoundColumn>
                                                <telerik:GridTemplateColumn HeaderText ="Linked Page Name" UniqueName="PageID">
                                                    <ItemTemplate>
                                                        <telerik:RadComboBox ID="PageComboBox"  Filter="Contains" Width="300px" DataSourceID="PageObjectDataSource" Height="250px" runat="server" SelectedValue='<%#Bind("PageID")%>' DataTextField="PageName" DataValueField="PageId" />                                                           
                                                   </ItemTemplate>
                                                </telerik:GridTemplateColumn>
                                            </Columns>
                                            <NoRecordsTemplate>
                                                <div style="margin-left: 5px;">No records found</div>
                                            </NoRecordsTemplate>
                                        </MasterTableView>
                                        <ItemStyle Height="30" />
                                        <AlternatingItemStyle Height="30" />
                                        <SelectedItemStyle BackColor="Fuchsia" BorderColor="Purple" BorderStyle="Dashed" BorderWidth="1px" />
                                        <ClientSettings>
                                            <Scrolling UseStaticHeaders ="true" AllowScroll="true" ScrollHeight="420px" />
                                        </ClientSettings>
                                    </telerik:RadGrid>

                                </div>
                            </td>
                        </tr>
                    </table>
                     <div class="divButtons" style="margin-top: 30px;">
                                    <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20"  />
                                    <telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="Web20" />
                                </div>

                </div>

            </div>



        </div>



    </form>
</body>
</html>
