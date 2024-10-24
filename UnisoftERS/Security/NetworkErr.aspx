<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Security_NetworkErr" Codebehind="NetworkErr.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>HD Clinical Network</title>
    <link href="../Styles/Site.css" rel="stylesheet" />
</head>
<body>
    <form id="mainForm" runat="server">
    <div class="sysMessage" style="width: 100%; margin-top: 100px; text-align: center;">
       <table id="tableMaintenance" border="0" runat="server" cellspacing="30" cellpadding="0" style="align-items: center; width: 100%;">
           <tr>
                <td><img src="../Images/NewLogo_198_83.png" /></td>
           </tr>
           <tr>
               <td><b>ERS Network</b></td>
           </tr>
           <tr>
               <td style="font-size: 0.7em;">We're sorry, this system is configured to be used in a local network only.<br />Please contact your system administrator.</td>
           </tr>
           <tr>
               <td style="height: 15px;">&nbsp;</td>
           </tr>
       </table>
    </div>
    </form>
</body>
</html>
