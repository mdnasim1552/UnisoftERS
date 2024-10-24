<%@ Page Language="VB" MasterPageFile="~/Templates/Unisoft.master" AutoEventWireup="true" Inherits="UnisoftERS.Products_Reports_ReportsMain" Codebehind="ReportsMain.aspx.vb" %>

<%--<%@ Register Assembly="Telerik.ReportViewer.WebForms, Version=9.2.15.930, Culture=neutral, PublicKeyToken=a9d7983dfcc261be" Namespace="Telerik.ReportViewer.WebForms" TagPrefix="telerik" %>--%>


<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContentPlaceHolder" runat="Server">
    <title>Site Details</title>
    <script type="text/javascript" src="../../Scripts/jquery-1.11.0.min.js"></script>
    <style type="text/css">
        .AutoHeight {
            height: auto !important;
        }
    </style>
    
    <script type="text/javascript">
        var baseUrl = "<%= ResolveUrl("~/") %>";

        var loadingPanel = null;
        var pane = null;
        var contentElement = null;

        function HideLoadingPanel() {
            //debugger;
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
                // debugger;
                loadingPanel.show(contentElement);
            }
        }

        function AlertFromParent() {
            alert("Hey I am parent");
        }
    </script>
</asp:Content>

<asp:Content ID="LeftPaneContent" runat="server" ContentPlaceHolderID="LeftPaneContentPlaceHolder">
    <div class="treeListBorder" style="margin-top: -5px;">
        <telerik:RadTreeView ID="LeftMenuTreeView" runat="server" OnClientNodeClicked="ClientNodeClicked" Skin="Default" BackColor="#ffffff" cssclass="treeviewBackground" width="300px"    />
    </div>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyContentPlaceHolder" runat="Server">

    <div style="margin: 12px 15px;">
        <telerik:RadTabStrip ID="RadTabStrip1" runat="server" SelectedIndex="3" Skin="Web20">
            <Tabs>
                <telerik:RadTab Text="Parameters" ImageUrl="../../../Images/Flags/brazil.gif">
                </telerik:RadTab>
                <telerik:RadTab Text="Preview" ImageUrl="../../../Images/Flags/it.gif">
                </telerik:RadTab>
            </Tabs>
        </telerik:RadTabStrip>
    </div>



    <div style="margin: 2px 5px;">
        <telerik:RadTabStrip ID="PrevProcSummaryTabStrip" runat="server" Skin="Web20" SelectedIndex="0" MultiPageID="RMPPrevProcs">
            <Tabs>
                <telerik:RadTab Text="Parameters" />
                <telerik:RadTab Text="Preview" />
            </Tabs>
        </telerik:RadTabStrip>

        <telerik:RadMultiPage ID="RMPPrevProcs" runat="server" SelectedIndex="0" >
            <telerik:RadPageView ID="RPVImages" runat="server">

            </telerik:RadPageView>
            <telerik:RadPageView ID="RPVPrintOptions" runat="server">
                <div style="background-color:red; vertical-align:top;  " >
                 <%--<telerik:ReportViewer ID="ReportViewer1" runat="server" Width="100%" Height="40" BorderColor="#FF0066" BorderWidth="1"></telerik:ReportViewer>--%>
                </div>
            </telerik:RadPageView>
        </telerik:RadMultiPage>
    </div>










   

    <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="frameNewProc" Skin="Web20" />
    <telerik:RadSplitter ID="RadSplitter1" runat="server">
        <telerik:RadPane ID="RadPane1" runat="server" ShowContentDuringLoad="false">
        </telerik:RadPane>
    </telerik:RadSplitter>
    
    
    <telerik:RadAjaxLoadingPanel ID="MyRadAjaxLoadingPanel1" runat="server" Skin="WebBlue">
    </telerik:RadAjaxLoadingPanel>
</asp:Content>

