<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Security_Admin" Codebehind="Admin.aspx.vb" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Remote Admin</title>
    <link href="../Styles/Site.css" rel="stylesheet" />
</head>
<body>
    <form id="mainForm" runat="server">
    <telerik:RadScriptManager ID="RadScriptManager" runat="server" />
    <div class="rptText">
        <table id="tableMaintenance" border="0" runat="server" cellspacing="0" cellpadding="0">
            <tr>
                <td style="height: 100px;" colspan="4">&nbsp;</td>
            </tr>
            <tr>
                <td style="width: 50px;">&nbsp;</td>
                <td>Current system status:&nbsp;&nbsp;</td>
                <td style="width: 100px;"><asp:Label ID="lblStatus" runat="server" Text=""></asp:Label></td>
                <td><asp:Button ID="cmdSetStatus" runat="server" Text="" /></td>
            </tr>

        </table>
    </div>
    </form>
</body>
</html>
