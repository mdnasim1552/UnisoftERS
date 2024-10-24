<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="GRSC01.aspx.vb" Inherits="UnisoftERS.GRSC01" %>
<%@ Register assembly="Microsoft.ReportViewer.WebForms, Version=11.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91" namespace="Microsoft.Reporting.WebForms" tagprefix="rsweb" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <asp:ScriptManager ID="ScriptManager1" runat="server">
        </asp:ScriptManager>
        <rsweb:ReportViewer ID="RV" runat="server" Font-Names="Verdana" Font-Size="8pt" WaitMessageFont-Names="Verdana" WaitMessageFont-Size="14pt" SizeToReportContent="true" CssClass="RVcss" >
            <LocalReport ReportEmbeddedResource="UnisoftERS.GRSC01.rdlc">
            </LocalReport>
        </rsweb:ReportViewer>
        <div id="PrintBtn"><img alt="Print report" src="../../../Images/icons/Print.png" /></div>    
    </div>
    </form>
</body>
</html>
