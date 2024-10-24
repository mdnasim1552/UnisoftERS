<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="Restricted.aspx.vb" Inherits="UnisoftERS.AccessRestricted" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form2" runat="server">
        <telerik:RadScriptManager ID="UnderConstructionRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="UnderConstructionRadFormDecorator" runat="server" DecoratedControls="All" DecorationZoneID="ContentDiv" Skin="Metro" />
        <div id="ContentDiv" style="font: 1.1em 'Segoe UI' , Arial, sans-serif;margin-left:20px;margin-top:20px;">
            <p>You do not have access to the page you are trying to access.</p>
            <p>Please contact the administrator.</p>
           <p><a href="javascript:window.parent.location = document.referrer;">Go back to previous page.</a></p>
          
        </div>
    </form>
</body>
</html>
