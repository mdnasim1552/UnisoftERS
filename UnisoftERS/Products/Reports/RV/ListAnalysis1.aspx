<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="ListAnalysis1.aspx.vb" Inherits="UnisoftERS.ListAnalysis1" %>
<%@ Register assembly="Microsoft.ReportViewer.WebForms" namespace="Microsoft.Reporting.WebForms" tagprefix="rsweb" %>
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
        <rsweb:ReportViewer ID="RV" runat="server" Font-Names="Verdana" Font-Size="8pt" WaitMessageFont-Names="Verdana" WaitMessageFont-Size="14pt" SizeToReportContent="true" CssClass="RVcss" KeepSessionAlive="False" >
            <LocalReport ReportEmbeddedResource="UnisoftERS.ListAnalysis-1A.rdlc">
            </LocalReport>
        </rsweb:ReportViewer>
        <div id="PrintBtn"><img alt="Print report" src="../../../Images/icons/Print.png" /></div>
    </div>
    </form>
</body>
</html>
