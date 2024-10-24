<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="ListGender.aspx.vb" Inherits="UnisoftERS.ListGender" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="../../../Scripts/jquery-3.6.3.min.js"></script>
    <script src="../../../Scripts/global.js"></script>

    <link href="../../../Styles/Site.css" rel="stylesheet" />
</head>
<body>
    <form id="form1" runat="server">
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Metro" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />


        <div id="FormDiv">
                
        </div>
    </form>
</body>
</html>
