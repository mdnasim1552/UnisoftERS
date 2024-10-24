<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_UnderConstruction" Codebehind="UnderConstruction.aspx.vb" %>

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
        <telerik:RadScriptManager ID="UnderConstructionRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="UnderConstructionRadFormDecorator" runat="server" DecoratedControls="All" DecorationZoneID="ContentDiv" Skin="Windows7" />
        <div class="text12">Under Construction</div>
        <div id="ContentDiv" style="font: 1.1em 'Segoe UI' , Arial, sans-serif;margin-left:20px;margin-top:20px;">
            This page is under construction. 
        </div>
    </form>
</body>
</html>
