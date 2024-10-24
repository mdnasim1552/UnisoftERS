<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="GRSA01.aspx.vb" Inherits="UnisoftERS.GRSA01" %>
<%@ Register assembly="Microsoft.ReportViewer.WebForms" namespace="Microsoft.Reporting.WebForms" tagprefix="rsweb" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <!-- #include virtual="_RVHeading.aspx"-->
</head>
<body>
    <form id="form1" runat="server">
    <div >    
        <asp:ScriptManager ID="ScriptManager1" runat="server">
        </asp:ScriptManager>
        <rsweb:ReportViewer ID="RV" runat="server" Font-Names="Verdana" Font-Size="8pt" WaitMessageFont-Names="Verdana" WaitMessageFont-Size="14pt" SizeToReportContent="true" CssClass="RVcss" >
            <LocalReport ReportEmbeddedResource="UnisoftERS.GRSA01.rdlc">
            </LocalReport>
        </rsweb:ReportViewer>
        <div id="PrintBtn"><img alt="Print report" src="../../../Images/icons/Print.png" /></div>
    </div>
    </form>
</body>
</html>
