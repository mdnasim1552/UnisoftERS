<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="SiteDetails.ascx.vb" Inherits="UnisoftERS.SiteDetails" %>
<telerik:RadSplitter ID="SiteDetailsRadSplitter2" runat="server" Height="490px" BorderWidth="1" Orientation="Vertical" Skin="Windows7">
    <telerik:RadPane ID="SiteDetailsMenuRadPane2" runat="server" Width="250px" Scrolling="Y" BackColor="#dfe9f5">
        <div class="treeListBorder" style="margin-top: 5px;">
            <telerik:RadTreeView ID="SiteDetailsMenuRadTreeView" runat="server" OnClientNodeClicked="ClientNodeClicked" Skin="Office2007"></telerik:RadTreeView>
        </div>
    </telerik:RadPane>
    <telerik:RadSplitBar ID="SiteDetailsRadSplitbar2" runat="server" CollapseMode="Forward" Visible="false" />
    <telerik:RadPane ID="SiteDetailsRadPane2" runat="server" Width="800px" BackColor="White">
    </telerik:RadPane>
</telerik:RadSplitter>