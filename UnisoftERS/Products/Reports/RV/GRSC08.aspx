<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="GRSC08.aspx.vb" Inherits="UnisoftERS.GRSC08" %>
<%@ Register assembly="Microsoft.ReportViewer.WebForms, Version=11.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91" namespace="Microsoft.Reporting.WebForms" tagprefix="rsweb" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <!-- #include virtual="_RVHeading.aspx"-->
</head>
<body>
    <form id="form1" runat="server">
    <div id="ReportContainer">
        <asp:ScriptManager ID="ScriptManager1" runat="server">
        </asp:ScriptManager>
        <rsweb:ReportViewer ID="RV" runat="server" Font-Names="Verdana" Font-Size="8pt" WaitMessageFont-Names="Verdana" WaitMessageFont-Size="14pt" CssClass="RVcss" SizeToReportContent="true" >
            <LocalReport ReportEmbeddedResource="UnisoftERS.GRSC08.rdlc">
            </LocalReport>
        </rsweb:ReportViewer>
        <div id="PrintBtn"><img alt="Print report" src="../../../Images/icons/Print.png" /></div>
    </div>
    </form>
</body>
</html>
