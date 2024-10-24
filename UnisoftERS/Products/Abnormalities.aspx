<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Abnormalities" Codebehind="Abnormalities.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../Scripts/jquery-3.6.3.min.js"></script>
    <link type="text/css" href="../Styles/Site.css" rel="stylesheet" />
    <script type="text/javascript"></script>
</head>
<body> 
    <form id="form1" runat="server">

        <telerik:RadScriptManager ID="AbnormalitiesRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="AbnormalitiesRadFormDecorator" runat="server" DecoratedControls="All" DecorationZoneID="ContentDiv" Skin="Web20" />
        <div class="abnorHeader">Abnormalities</div>
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Height="505px" Scrolling="Y">
                <div id="ContentDiv">
            
                </div>
            </telerik:RadPane>
        </telerik:RadSplitter>

    </form>
</body>
</html>
