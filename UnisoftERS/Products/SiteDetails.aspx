
<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_SiteDetails" CodeBehind="SiteDetails.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Site Details</title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../Scripts/global.js"></script>
    <style type="text/css">
        .procedureHeight,#RAD_SPLITTER_PANE_EXT_CONTENT_SiteDetailsRadPane,#RAD_SPLITTER_PANE_CONTENT_SiteDetailsMenuRadPane{
            height: calc(90vh - 25px) !important;
        }

        #SiteDetailsMenuRadTreeView {
            margin-bottom: 25px!important;
        }

        .aspxValidator {
            font-size: 1.2em;
            font-weight: bold;
            color: red;
            vertical-align: middle;
        }

        .aspxValidationSummary {
            border: none;
            background-color: transparent;
            font-family: "Helvetica Neue", "Lucida Grande", "Segoe UI", Arial, Helvetica, Verdana, sans-serif;
            color: red;
            font-size: 1.2em;
            display: block;
            padding-top: 20px;
            padding-bottom: 20px;
            padding-left: 20px;
            padding-right: 20px;
        }

        .aspxValidationSummaryHeader {
            font-weight: bold;
            font-family: "Helvetica Neue", "Lucida Grande", "Segoe UI", Arial, Helvetica, Verdana, sans-serif;
            height: 20px;
            font-size: 1.0em;
        }

        .aspxValidationSummary ul li {
            margin-left: 5px;
        }

        #ValidationNotification {
            display: none;
            border-color: #6788be;
            color: #333;
            background-color: #fff;
            font-size: 12px;
            font-family: "Segoe UI",Arial,Helvetica,sans-serif;
            box-shadow: 2px 2px 3px #6788be;
            position: fixed;
            width: 500px;
            z-index: 10000;
            visibility: visible;
            left: 20%;
            top: 30%;
            border-radius: .41666667em;
            box-sizing: content-box;
            margin: 0;
            padding: 0;
            border-width: 1px;
            border-style: solid;
            word-wrap: break-word;
            overflow: hidden;
        }

        #ValidationNotification .rnTitleBar {
            border-color: #5f90cf;
            color: #fff;
            background-color: #92b3de;
            background-image: linear-gradient(#9db7db,#7b95c6 50%,#698ac0 50%,#92b3de);
            border-bottom-color: inherit;
            margin: 0;
            padding: 4px;
            line-height: 1.25;
            border-bottom-width: 1px;
            border-bottom-style: solid;
            background-repeat: repeat-x;
            background-position: 0 0;
            border-radius: .41666667em .41666667em 0 0;
        }

        #ValidationNotification .rnCommands {
            margin: 0;
            padding: 0;
            width: auto;
            float: right;
            list-style: none;
        }

        .validation-modal {
            display: none;
            position: absolute;
            left: 0px;
            top: 0px;
            z-index: 9999;
            background-color: rgb(170, 170, 170);
            opacity: 0.5;
            width: 100%;
            height: 100%;
        }
        #RadWindowWrapper_NodeChangeAlertRadWindow{
            left: 200px !important;
            top: 128px !important;
            background-color: red;
        }
        .selectedNode{
            font-weight: bold;
            color: #005999;
        }
        .unselectedNode{
            font-weight: normal !important;
            color: #101010 !important;
        }
        #NodeChangeAlertRadWindow_C{
            width: 485px !important;
            height: 165px !important;
        }
        #NodeChangeAlertRadWindow_C_lblMessage{
            color: red;
        }
        #RadWindowWrapper_NodeChangeAlertRadWindow{
            width: 485px !important;
        }
    </style>
</head>

<body>
    <script type="text/javascript">
        var baseUrl = "<%= ResolveUrl("~/") %>";
        var loadingPanel = null;
        var pane = null;
        var contentElement = null;
        var contentElement = null;
        var changeNode = null;
        $(window).on('load', function () {
            var tree = $find("<%= SiteDetailsMenuRadTreeView.ClientID%>");
            var node = tree.get_selectedNode();
            if (node != null) {
                if (node.get_nodes().get_count() == 0) {
                    SetUrl(node);
                }
                else {
                    node.expand();
                    //SetUrl(node.get_allNodes()[0]);
                    SetUrl(node);
                }
            }
        });

        $(document).ready(function () {          
            $('#<%=ContinueRadButton.ClientID%>').on('click', function () {
                var oWnd = $find("<%=NodeChangeAlertRadWindow.ClientID%>");
                oWnd.close();
                if (changeNode !== null) {
                    selectTreeNodeAndSetURL(changeNode, true);
                    previousSelectedNode = changeNode;
                }
                localStorage.clear();
            });
            $('#<%=CancelRadButton.ClientID%>').on('click', function () {
                var oWnd = $find("<%=NodeChangeAlertRadWindow.ClientID%>");
                oWnd.close();
            });
            
        });

        function selectTreeNodeAndSetURL(nodeToCheck, setURL) {
            setTimeout(function () {
                if (nodeToCheck != null && nodeToCheck.get_value().indexOf('ProcedureSummary') == -1) nodeToCheck.get_parent().expand();
                nodeToCheck.select();
                if (setURL === true) SetUrl(nodeToCheck);
                if (localStorage.getItem("valueChanged") === "true") nodeToCheck.set_cssClass('selectedNode');
            }, 1);
        }

        function HideLoadingPanel() {

            if (loadingPanel && pane) {
                loadingPanel.hide(contentElement);
                loadingPanel = null;
                pane = null;
            }
        }

        function ClientNodeClicked(sender, eventArgs) {
            changeNode = eventArgs.get_node();
            if (localStorage.getItem("validationRequired") === "true") {
                selectTreeNodeAndSetURL(previousSelectedNode, false);
                var oWnd = $find("<%=NodeChangeAlertRadWindow.ClientID%>");
                $('#<%= lblMessage.ClientID%>').html(localStorage.getItem("validationRequiredMessage"));
                oWnd.show();
                return;
            }
            HideLoadingPanel();
            var node = eventArgs.get_node();
            SetUrl(node);
            if (localStorage.getItem("valueChanged") !== null) updateNodeColor(previousSelectedNode, localStorage.getItem("valueChanged"));
            previousSelectedNode = node;
            var parentBtn = $(window.parent.document).find("#ctl00_ctl00_BodyContentPlaceHolder_pBodyContentPlaceHolder_MarkAreaButton_input");           
            if(parentBtn.val()=="Done"){
                parentBtn.click();
            }
            var refreshBtn = $(window.parent.document).find("#ctl00_ctl00_BodyContentPlaceHolder_pBodyContentPlaceHolder_RefreshDiagramButton_input");
            refreshBtn.click();
        }

        function updateNodeColor(nodeToChangeColor, changeColor) {
            localStorage.clear();
            setTimeout(function () {
                if (changeColor === 'true') {
                    nodeToChangeColor.set_cssClass('selectedNode');
                    if (nodeToChangeColor.get_parent().get_text() === 'Abnormalities') nodeToChangeColor.get_parent().set_cssClass('selectedNode');
                }
                else if (changeColor === 'false') {
                    nodeToChangeColor.set_cssClass('unselectedNode');
                    for (var i = 0; i < nodeToChangeColor.get_parent().get_allNodes().length; i++) {
                        var getClass = nodeToChangeColor.get_parent().get_allNodes()[i].get_cssClass();
                        if (getClass === 'selectedNode') {
                            if (nodeToChangeColor.get_parent().get_text() === 'Abnormalities') nodeToChangeColor.get_parent().set_cssClass('selectedNode');
                            return;
                        }
                    }
                    if (nodeToChangeColor.get_parent().get_text() === 'Abnormalities') nodeToChangeColor.get_parent().set_cssClass('unselectedNode');
                }
            }, 1);
        }

        function ResolveUrl(url) {
            if (url.indexOf("/Abnormalities.aspx") > 0) {
                //alert(url);
                //url =  "/Products/Abnormalities.aspx";
                url = "Abnormalities.aspx";
            }
            else if (url.indexOf("~/") == 0) {

                //alert(baseUrl + url.substring(2) + " --- " + url)
                url = baseUrl + url.substring(2);
            }
            return url;
        }

        function SetUrl(node) {

            pane = $find("<%= SiteDetailsRadPane.ClientID %>");
            var iframe = pane.getExtContentElement();
            var url = node.get_value();
            HideLoadingPanel();
            if (url != null) {
                url = ResolveUrl(url);
                if (pane != null) pane.set_contentUrl(url);

                contentElement = "RAD_SPLITTER_PANE_CONTENT_<%=SiteDetailsRadPane.ClientID %>";
                loadingPanel = $find("<%= MyRadAjaxLoadingPanel1.ClientID%>");
                loadingPanel.show(contentElement);
            }
            if (url.includes("AttachedMedia.aspx")) {
                setTimeout(function () {
                    HideLoadingPanel();
                }, 300);
            }          
        }

        //function called from SiteSummary.aspx which is child form of SiteDetails.aspx
        function selectNode(text) {
            var treeView = $find("<%= SiteDetailsMenuRadTreeView.ClientID%>");
            var selectedNode = treeView.get_selectedNode();
            selectedNode.expand();
            setTimeout(function () {
                var allNodes = selectedNode.get_allNodes();
                for (var i = 0; i < allNodes.length; i++) {
                    var node = allNodes[i];
                    if (node.get_text() === text) {
                        node.select(); 
                        SetUrl(node);
                    }
                }
            }, 1500);
        }

        function selectSpecificNode(text) {
            var treeView = $find("<%= SiteDetailsMenuRadTreeView.ClientID%>");
            var selectedNode = treeView.get_selectedNode();
            selectedNode.expand();
            setTimeout(function () {
                var allNodes = selectedNode.get_parent().get_allNodes();
                for (var i = 0; i < allNodes.length; i++) {
                    var node = allNodes[i];
                    if (node.get_text() === text) {
                        node.select(); 
                        SetUrl(node);
                    }
                }
            }, 1500);
        }

        function AlertFromParent() {
            alert("Hey I am parent");
        }

        function CloseWindow() {
            var oWindow = GetRadWindow();
            oWindow.close();
        }

        function GetRadWindow() {
            var oWindow = null; if (window.radWindow)
                oWindow = window.radWindow; else if (window.frameElement.radWindow)
                oWindow = window.frameElement.radWindow; return oWindow;
        }

        function setRehideSummary() {
            parent.setRehideSummary();
        }

        function refreshDiagramGastritis(siteid) {
            parent.refreshDiagramGastritis(siteid);
        }

        function refreshParentWithDiagram() {
            parent.refreshParentWithDiagram();
        }

        function getParentNode() {
            var currentNode = $find("<%= SiteDetailsMenuRadTreeView.ClientID %>");
            var parentNode = currentNode.get_selectedNode().get_parent().get_parent();
            parentNode.select();
            SetUrl(parentNode);

        }

        function closeNotificationWindow() {
            $('#masterValDiv').html("");
            $('#ValidationNotification').hide();
            $('.validation-modal').hide();
        }

        <%---function SplitterLoaded(splitter, arg) {
            var pane = splitter.getPaneById('<%= SiteDetailsRadPane.ClientID %>');
            //debugger;
            var height = getCookie("screenSize") - 210; 
            splitter.set_height(height);
            pane.set_height(height);
        }
        --%>

        function getCookie(cname) {
            let name = cname + "=";
            let ca = document.cookie.split(';');
            for (let i = 0; i < ca.length; i++) {
                let c = ca[i];
                while (c.charAt(0) == ' ') {
                    c = c.substring(1);
                }
                if (c.indexOf(name) == 0) {
                    return c.substring(name.length, c.length);
                }
            }
            return "";
        }

        function triggerProcedurePage() {
            var mediaSiteId = $('#SiteDetailsBtn').attr('data-mediaSiteId');
            var btn = $(window.parent.document).find('#ProcedureBtn');
            btn.attr('data-mediaSiteId', mediaSiteId);
            btn.click();
        }

    </script>

    <form id="SiteDetailsForm" runat="server">
        <telerik:RadButton runat="server" ID ="SiteDetailsBtn" AutoPostBack="false" Text="" ClientIDMode="Static" OnClientClicking="triggerProcedurePage" data-mediaSiteId="" style="display: none"></telerik:RadButton>
        <telerik:RadNotification ID="RadNotification1" runat="server" AutoCloseDelay="0" VisibleOnPageLoad="false" />
        <div class="validation-modal"></div>
        <div id="ValidationNotification">
            <div class="rnTitleBar">
                <span class="rnTitleBarIcon"></span><span class="rnTitleBarTitle">Please correct the following</span>
                <ul class="rnCommands">
                    <li class="rnCloseIcon"><a href="javascript:void(0);" title="Close"></a></li>
                </ul>
            </div>
            <div id="masterValDiv" class="aspxValidationSummary"></div>
            <div style="height: 20px; margin: 0 5px 5px 10px; float: right">
                <telerik:RadButton ID="CloseNotificationButton" runat="server" Text="Close" Skin="Metro" AutoPostBack="false" OnClientClicked="closeNotificationWindow" ButtonType="SkinnedButton"
                    Icon-PrimaryIconCssClass="telerikCloseButton" />
            </div>
        </div>
        <telerik:RadScriptManager ID="SiteDetailsRadScriptManager" runat="server" />
        <%--  Design Section for Procedure details  --%>
        <telerik:RadSplitter ID="SiteDetailsRadSplitter" runat="server" CssClass="procedureHeight" BorderWidth="1" Orientation="Vertical" Skin="Windows7">
            <telerik:RadPane ID="SiteDetailsMenuRadPane" runat="server" Scrolling="Y" Width="250px" BackColor="#dfe9f5">
                <div class="treeListBorder" style="margin-top: 5px;">
                    <telerik:RadTreeView ID="SiteDetailsMenuRadTreeView" runat="server" OnClientNodeClicked="ClientNodeClicked" Skin="WebBlue"></telerik:RadTreeView>
                </div>
            </telerik:RadPane>
            <telerik:RadSplitBar ID="SiteDetailsRadSplitbar" runat="server" CollapseMode="Forward" Visible="false" />
            <telerik:RadPane ID="SiteDetailsRadPane" runat="server" Scrolling="Y" Width="800px" CssClass="procedureHeight">
            </telerik:RadPane>
        </telerik:RadSplitter>

        <telerik:RadAjaxLoadingPanel ID="MyRadAjaxLoadingPanel1" runat="server" Skin="Metro">
        </telerik:RadAjaxLoadingPanel>

        <telerik:RadWindowManager ID="SiteDetailsRadWindowManager" runat="server" ShowContentDuringLoad="False" Style="z-index: 7001" Behaviors="Close, Move, Resize" Skin="Metro" EnableShadow="true" Modal="true">
            <Windows>
                <telerik:RadWindow ID="NodeChangeAlertRadWindow" runat="server" Modal="true" ReloadOnShow="true" KeepInScreenBounds="true" Height="250px" VisibleStatusbar="false" VisibleOnPageLoad="false" Title="Unsaved Changes" BackColor="#ffffcc" Left="100px">
                    <ContentTemplate>
                        <table width="100%">
                            <tr>
                                <td style="vertical-align: middle; padding-left: 20px; padding-top: 30px">
                                    <img id="Img1" runat="server" src="~/Images/info-24x24.png" alt="icon" />
                                </td>
                                <td style="text-align: center; padding: 20px; height: 110px; overflow-y:auto">
                                    <asp:Label ID="lblMessage" runat="server" Font-Size="Medium" Text="Do you wish to continue?" />
                                </td>
                            </tr>
                            <tr>
                                <td></td>
                                <td style="padding-left: 100px; text-align: center; position: fixed">
                                    <telerik:RadButton ID="ContinueRadButton" runat="server" Text="Continue" Skin="Windows7" ButtonType="SkinnedButton" Font-Size="Large" AutoPostBack="false" Style="margin-right: 20px;" OnClientClicked="" />
                                    <telerik:RadButton ID="CancelRadButton" runat="server" Text="Cancel" Skin="Windows7" ButtonType="SkinnedButton" AutoPostBack="false" OnClientClicked="" Font-Size="Large" />
                                </td>
                            </tr>
                        </table>
                    </ContentTemplate>
                </telerik:RadWindow>
            </Windows>
        </telerik:RadWindowManager>

    </form>
</body>
</html>
