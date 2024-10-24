<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Security_Maintenance" Codebehind="Maintenance.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>HD Clinical Maintenance</title>
    <link href="../Styles/Site.css" rel="stylesheet" />
</head>
<body>
    <form id="mainForm" runat="server">
    <div class="sysMessage" style="width: 100%; margin-top: 100px; text-align: center;">
       <table id="tableMaintenance" border="0" runat="server" cellspacing="0" cellpadding="0" style="align-items: center; width: 100%;">
           <tr>
                <td><img src="../Images/NewLogo_198_83.png" /></td>
           </tr>
           <tr>
               <td><b>System down for essential maintenance</b></td>
           </tr>
           <tr>
               <td style="font-size: 0.7em;">We're sorry, this system is not available at this time,<br />please try again later.</td>
           </tr>
           <tr>
               <td style="height: 15px;">&nbsp;</td>
           </tr>
           <tr>
               <td style="font-size: 0.5em;"><asp:HyperLink ID="HyperLink1" runat="server" NavigateUrl="~/Security/SELogin.aspx">Return to Login Screen</asp:HyperLink></td>
           </tr>
       </table>
    </div>
    </form>
</body>
</html>
