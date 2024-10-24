<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Common_SiteSummary" Codebehind="SiteSummary.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../Scripts/global.js"></script>
    <link type="text/css" href="../../Styles/Site.css" rel="stylesheet" />

    <style type="text/css">
        a.sitesummary {
            color: inherit;
        }

        a.sitesummary:link {
            text-decoration: none;
            color: inherit;
        }

        a.sitesummary:hover {
            text-decoration: underline;
            color: blue;
        }
    </style>

    <script type="text/javascript">
        function CloseWindow() {
            window.parent.CloseWindow();
        }

        function OpenSiteDetails(region, siteId, optionChosen) {
            //Call funtion selectNode from SiteDetails.aspx to select the required node.
            if (optionChosen == "Barretts Epithelium") optionChosen = "Barrett's";
            window.parent.selectNode(optionChosen);
        }

      

        </script>
</head>
<body>
    <form id="form1" runat="server">
        <telerik:RadScriptManager ID="CalibreRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator2" runat="server" DecoratedControls="All" DecorationZoneID="ContentDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
       
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
        <div id="abnorHeader" class="abnorHeader" runat="server">Site Summary</div>
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Height="560px" Scrolling="Y"><telerik:RadAjaxPanel ID="RadAjaxPanel1" runat="server">
                <div id="ContentDiv" style="padding-left: 8px;">
                    <asp:Label ID="SiteSummaryLabel" runat="server" Font-Size="Small" />
                </div>
         </telerik:RadAjaxPanel>   </telerik:RadPane>
            <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px" CssClass="SiteDetailsButtonsPane">
             
            </telerik:RadPane>
        </telerik:RadSplitter>
        <div>
        </div>
    
        </ContentTemplate>
        </asp:UpdatePanel>

    </form>
</body>
</html>
