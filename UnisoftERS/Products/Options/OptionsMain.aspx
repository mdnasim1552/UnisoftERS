<%@ Page Language="VB" MasterPageFile="~/Templates/Unisoft.master" AutoEventWireup="true" Inherits="UnisoftERS.Products_Options_OptionsMain" CodeBehind="OptionsMain.aspx.vb" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContentPlaceHolder" runat="Server">
    <title>Site Details</title>
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <style type="text/css">
        .AutoHeight {
            height: calc(100vh - 120px) !important;
        }
    </style>

    <script type="text/javascript">
        var baseUrl = "<%= ResolveUrl("~/") %>";

        var loadingPanel = null;
        var pane = null;
        var contentElement = null;

        function HideLoadingPanel() {

            if (loadingPanel && pane) {
                loadingPanel.hide(contentElement);
                loadingPanel = null;
                pane = null;
            }
        }

        function ClientNodeClicked(sender, eventArgs) {
            HideLoadingPanel();

            var node = eventArgs.get_node();
            if (node.get_nodes().get_count() == 0) {
                SetUrl(node);
            }
            else {
                node.expand();
                SetUrl(node.get_allNodes()[0]);
                node.get_allNodes()[0].select();
            }
        }

        function ResolveUrl(url) {
            if (url.indexOf("~/") == 0) {
                url = baseUrl + url.substring(2);
            }
            return url;
        }

        function SetUrl(node) {
            var url = node.get_value();
            if (url != null) {
                url = ResolveUrl(url);

                var splitter = $find("<%=RadSplitter1.ClientID %>");
                pane = splitter.getPaneById("<%= RadPane1.ClientID %>");
                pane.set_contentUrl(url);
                contentElement = "RAD_SPLITTER_PANE_CONTENT_<%=RadPane1.ClientID %>";
                loadingPanel = $find("<%= MyRadAjaxLoadingPanel1.ClientID%>");

                loadingPanel.show(contentElement);
            }
        }
    </script>
</asp:Content>

<asp:Content ID="LeftPaneContent" runat="server" ContentPlaceHolderID="LeftPaneContentPlaceHolder">
    <div class="treeListBorder" style="margin-top: -5px;">
        <telerik:RadTreeView ID="LeftMenuTreeView" runat="server" OnClientNodeClicked="ClientNodeClicked" Skin="Default" BackColor="#f2f9fc" Width="280px" CssClass="OptionsBackgroundPane AutoHeight"/>
    </div>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyContentPlaceHolder" runat="Server">


    <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="frameNewProc" Skin="Web20" />
    <telerik:RadSplitter ID="RadSplitter1" runat="server">
        <telerik:RadPane ID="RadPane1" runat="server" ShowContentDuringLoad="false">
        </telerik:RadPane>
    </telerik:RadSplitter>


    <telerik:RadAjaxLoadingPanel ID="MyRadAjaxLoadingPanel1" runat="server" Skin="Metro">
    </telerik:RadAjaxLoadingPanel>
</asp:Content>

